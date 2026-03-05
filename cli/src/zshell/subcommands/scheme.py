import typer
import json
import shutil
import os

from jinja2 import Environment, FileSystemLoader, StrictUndefined, Undefined
from typing import Any, Optional, Tuple
from zshell.utils.schemepalettes import PRESETS
from pathlib import Path
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct.hct import Hct

app = typer.Typer()


@app.command()
def generate(
    # image inputs (optional - used for image mode)
    image_path: Optional[Path] = typer.Option(
        None, help="Path to source image. Required for image mode."),
    scheme: Optional[str] = typer.Option(
        "fruit-salad", help="Color scheme algorithm to use for image mode. Ignored in preset mode."),
    # preset inputs (optional - used for preset mode)
    preset: Optional[str] = typer.Option(
        None, help="Name of a premade scheme in this format: <preset_name>:<preset_flavor>"),
    mode: Optional[str] = typer.Option(
        "dark", help="Mode of the preset scheme (dark or light)."),
):

    if preset is not None and image_path is not None:
        raise typer.BadParameter(
            "Use either --image-path or --preset, not both.")

    match scheme:
        case "fruit-salad":
            from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme
        case 'expressive':
            from materialyoucolor.scheme.scheme_expressive import SchemeExpressive as Scheme
        case 'monochrome':
            from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome as Scheme
        case 'rainbow':
            from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow as Scheme
        case 'tonal-spot':
            from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
        case 'neutral':
            from materialyoucolor.scheme.scheme_neutral import SchemeNeutral as Scheme
        case 'fidelity':
            from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity as Scheme
        case 'content':
            from materialyoucolor.scheme.scheme_content import SchemeContent as Scheme
        case 'vibrant':
            from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant as Scheme
        case _:
            from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme

    HOME = str(os.getenv("HOME"))
    OUTPUT = Path(HOME + "/.local/state/zshell/scheme.json")
    THUMB_PATH = Path(HOME +
                      "/.cache/zshell/imagecache/thumbnail.jpg")
    WALL_DIR_PATH = Path(HOME +
                         "/.local/state/zshell/wallpaper_path.json")

    TEMPLATE_DIR = Path(HOME + "/.config/zshell/templates")
    WALL_PATH = Path()

    with WALL_DIR_PATH.open() as f:
        path = json.load(f)["currentWallpaperPath"]
        WALL_PATH = path

    def generate_thumbnail(image_path, thumbnail_path, size=(128, 128)):
        thumbnail_file = Path(thumbnail_path)

        image = Image.open(image_path)
        image = image.convert("RGB")
        image.thumbnail(size, Image.NEAREST)

        thumbnail_file.parent.mkdir(parents=True, exist_ok=True)
        image.save(thumbnail_path, "JPEG")

    def build_template_context(
        *,
        colors: dict[str, str],
        seed: Hct,
        mode: str,
        wallpaper_path: str,
        name: str,
        flavor: str,
        variant: str,
    ) -> dict[str, Any]:
        ctx: dict[str, Any] = {
            "mode": mode,
            "wallpaper_path": wallpaper_path,
            "source_color": int_to_hex(seed.to_int()),
            "name": name,
            "seed": seed.to_int(),
            "flavor": flavor,
            "variant": variant,
            "colors": colors
        }

        for k, v in colors.items():
            ctx[k] = v
            ctx[f"m3{k}"] = v

        return ctx

    def parse_output_directive(first_line: str) -> Optional[Path]:
        s = first_line.strip()
        if not s.startswith("#") or s.startswith("#!"):
            return None

        target = s[1:].strip()
        if not target:
            return None

        expanded = os.path.expandvars(os.path.expanduser(target))
        return Path(expanded)

    def split_directive_and_body(text: str) -> Tuple[Optional[Path], str]:
        lines = text.splitlines(keepends=True)
        if not lines:
            return None, ""

        out_path = parse_output_directive(lines[0])
        if out_path is None:
            return None, text

        body = "".join(lines[1:])
        return out_path, body

    def render_all_templates(
        templates_dir: Path,
        context: dict[str, object],
        *,
        strict: bool = True,
    ) -> list[Path]:
        undefined_cls = StrictUndefined if strict else Undefined
        env = Environment(
            loader=FileSystemLoader(str(templates_dir)),
            autoescape=False,
            keep_trailing_newline=True,
            undefined=undefined_cls,
        )

        rendered_outputs: list[Path] = []

        for tpl_path in sorted(p for p in templates_dir.rglob("*") if p.is_file()):
            rel = tpl_path.relative_to(templates_dir)

            if any(part.startswith(".") for part in rel.parts):
                continue

            raw = tpl_path.read_text(encoding="utf-8")
            out_path, body = split_directive_and_body(raw)

            out_path.parent.mkdir(parents=True, exist_ok=True)

            try:
                template = env.from_string(body)
                text = template.render(**context)
            except Exception as e:
                raise RuntimeError(
                    f"Template render failed for '{rel}': {e}") from e

            out_path.write_text(text, encoding="utf-8")

            try:
                shutil.copymode(tpl_path, out_path)
            except OSError:
                pass

            rendered_outputs.append(out_path)

        return rendered_outputs

    def seed_from_image(image_path: Path) -> Hct:
        image = Image.open(image_path)
        pixel_len = image.width * image.height
        image_data = image.getdata()

        quality = 1
        pixel_array = [image_data[_] for _ in range(0, pixel_len, quality)]

        result = QuantizeCelebi(pixel_array, 128)
        return Hct.from_int(Score.score(result)[0])

    def seed_from_preset(name: str) -> Hct:
        try:
            return PRESETS[name].primary
        except KeyError:
            raise typer.BadParameter(
                f"Preset '{name}' not found. Available presets: {', '.join(PRESETS.keys())}")

    def generate_color_scheme(seed: Hct, mode: str) -> dict[str, str]:

        is_dark = mode.lower() == "dark"

        scheme = Scheme(
            seed,
            is_dark,
            0.0
        )

        color_dict = {}
        for color in vars(MaterialDynamicColors).keys():
            color_name = getattr(MaterialDynamicColors, color)
            if hasattr(color_name, "get_hct"):
                color_int = color_name.get_hct(scheme).to_int()
                color_dict[color] = int_to_hex(color_int)

        return color_dict

    def int_to_hex(argb_int):
        return "#{:06X}".format(argb_int & 0xFFFFFF)

    try:
        if preset:
            seed = seed_from_preset(preset)
            colors = generate_color_scheme(seed, mode)
            name, flavor = preset.split(":")
        elif image_path:
            generate_thumbnail(image_path, str(THUMB_PATH))
            seed = seed_from_image(THUMB_PATH)
            colors = generate_color_scheme(seed, mode)
            name = "dynamic"
            flavor = "default"
        elif mode and scheme is None:
            generate_thumbnail(WALL_PATH, str(THUMB_PATH))
            seed = seed_from_image(THUMB_PATH)
            colors = generate_color_scheme(seed, mode)
            name = "dynamic"
            flavor = "default"
        elif scheme:
            with OUTPUT.open() as f:
                js = json.load(f)
                seed = Hct.from_int(js["seed"])
                mode = str(js["mode"])

            colors = generate_color_scheme(seed, mode)
            name = "dynamic"
            flavor = "default"

        output_dict = {
            "name": name,
            "flavor": flavor,
            "mode": mode,
            "variant": scheme,
            "colors": colors,
            "seed": seed.to_int()
        }

        if TEMPLATE_DIR is not None:
            wp = str(WALL_PATH)
            ctx = build_template_context(
                colors=colors,
                seed=seed,
                mode=mode,
                wallpaper_path=wp,
                name=name,
                flavor=flavor,
                variant=scheme
            )

            rendered = render_all_templates(
                templates_dir=TEMPLATE_DIR,
                context=ctx,
            )

            for p in rendered:
                print(f"rendered: {p}")

        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        with open(OUTPUT, "w") as f:
            json.dump(output_dict, f, indent=4)
    except Exception as e:
        print(f"Error: {e}")
        # with open(output, "w") as f:
        #     f.write(f"Error: {e}")
