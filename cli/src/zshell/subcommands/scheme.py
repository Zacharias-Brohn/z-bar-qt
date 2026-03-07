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
from materialyoucolor.utils.color_utils import argb_from_rgb
from materialyoucolor.utils.math_utils import difference_degrees, rotation_direction, sanitize_degrees_double

app = typer.Typer()


@app.command()
def generate(
    # image inputs (optional - used for image mode)
    image_path: Optional[Path] = typer.Option(
        None, help="Path to source image. Required for image mode."),
    scheme: Optional[str] = typer.Option(
        None, help="Color scheme algorithm to use for image mode. Ignored in preset mode."),
    # preset inputs (optional - used for preset mode)
    preset: Optional[str] = typer.Option(
        None, help="Name of a premade scheme in this format: <preset_name>:<preset_flavor>"),
    mode: Optional[str] = typer.Option(
        None, help="Mode of the preset scheme (dark or light)."),
):

    HOME = str(os.getenv("HOME"))
    OUTPUT = Path(HOME + "/.local/state/zshell/scheme.json")
    SEQ_STATE = Path(HOME + "/.local/state/zshell/sequences.txt")
    THUMB_PATH = Path(HOME +
                      "/.cache/zshell/imagecache/thumbnail.jpg")
    WALL_DIR_PATH = Path(HOME +
                         "/.local/state/zshell/wallpaper_path.json")

    TEMPLATE_DIR = Path(HOME + "/.config/zshell/templates")
    WALL_PATH = Path()
    CONFIG = Path(HOME + "/.config/zshell/config.json")

    if preset is not None and image_path is not None:
        raise typer.BadParameter(
            "Use either --image-path or --preset, not both.")

    def get_scheme_class(scheme_name: str):
        match scheme_name:
            case "fruit-salad":
                from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad
                return SchemeFruitSalad
            case "expressive":
                from materialyoucolor.scheme.scheme_expressive import SchemeExpressive
                return SchemeExpressive
            case "monochrome":
                from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome
                return SchemeMonochrome
            case "rainbow":
                from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow
                return SchemeRainbow
            case "tonal-spot":
                from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
                return SchemeTonalSpot
            case "neutral":
                from materialyoucolor.scheme.scheme_neutral import SchemeNeutral
                return SchemeNeutral
            case "fidelity":
                from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity
                return SchemeFidelity
            case "content":
                from materialyoucolor.scheme.scheme_content import SchemeContent
                return SchemeContent
            case "vibrant":
                from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
                return SchemeVibrant
            case _:
                from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad
                return SchemeFruitSalad

    def hex_to_hct(hex_color: str) -> Hct:
        s = hex_color.strip()
        if s.startswith("#"):
            s = s[1:]
        if len(s) != 6:
            raise ValueError(f"Expected 6-digit hex color, got: {hex_color!r}")
        return Hct.from_int(int("0xFF" + s, 16))

    LIGHT_GRUVBOX = list(
        map(
            hex_to_hct,
            [
                "FDF9F3",
                "FF6188",
                "A9DC76",
                "FC9867",
                "FFD866",
                "F47FD4",
                "78DCE8",
                "333034",
                "121212",
                "FF6188",
                "A9DC76",
                "FC9867",
                "FFD866",
                "F47FD4",
                "78DCE8",
                "333034",
            ],
        )
    )

    DARK_GRUVBOX = list(
        map(
            hex_to_hct,
            [
                "282828",
                "CC241D",
                "98971A",
                "D79921",
                "458588",
                "B16286",
                "689D6A",
                "A89984",
                "928374",
                "FB4934",
                "B8BB26",
                "FABD2F",
                "83A598",
                "D3869B",
                "8EC07C",
                "EBDBB2",
            ],
        )
    )

    with WALL_DIR_PATH.open() as f:
        path = json.load(f)["currentWallpaperPath"]
        WALL_PATH = path

    def lighten(color: Hct, amount: float) -> Hct:
        diff = (100 - color.tone) * amount
        tone = max(0.0, min(100.0, color.tone + diff))
        chroma = max(0.0, color.chroma + diff / 5)
        return Hct.from_hct(color.hue, chroma, tone)

    def darken(color: Hct, amount: float) -> Hct:
        diff = color.tone * amount
        tone = max(0.0, min(100.0, color.tone - diff))
        chroma = max(0.0, color.chroma - diff / 5)
        return Hct.from_hct(color.hue, chroma, tone)

    def grayscale(color: Hct, light: bool) -> Hct:
        color = darken(color, 0.35) if light else lighten(color, 0.65)
        color.chroma = 0
        return color

    def harmonize(from_hct: Hct, to_hct: Hct, tone_boost: float) -> Hct:
        diff = difference_degrees(from_hct.hue, to_hct.hue)
        rotation = min(diff * 0.8, 100)
        output_hue = sanitize_degrees_double(
            from_hct.hue
            + rotation * rotation_direction(from_hct.hue, to_hct.hue)
        )
        tone = max(0.0, min(100.0, from_hct.tone * (1 + tone_boost)))
        return Hct.from_hct(output_hue, from_hct.chroma, tone)

    def terminal_palette(
        colors: dict[str, str], mode: str, variant: str
    ) -> dict[str, str]:
        light = mode.lower() == "light"

        key_hex = (
            colors.get("primary_paletteKeyColor")
            or colors.get("primaryPaletteKeyColor")
            or colors.get("primary")
            or int_to_hex(seed.to_int())
        )
        key_hct = hex_to_hct(key_hex)

        base = LIGHT_GRUVBOX if light else DARK_GRUVBOX
        out: dict[str, str] = {}

        is_mono = variant.lower() == "monochrome"

        for i, base_hct in enumerate(base):
            if is_mono:
                h = grayscale(base_hct, light)
            else:
                tone_boost = (0.35 if i < 8 else 0.2) * (-1 if light else 1)
                h = harmonize(base_hct, key_hct, tone_boost)

            out[f"term{i}"] = int_to_hex(h.to_int())

        return out

    def generate_thumbnail(image_path, thumbnail_path, size=(128, 128)):
        thumbnail_file = Path(thumbnail_path)

        image = Image.open(image_path)
        image = image.convert("RGB")
        image.thumbnail(size, Image.NEAREST)

        thumbnail_file.parent.mkdir(parents=True, exist_ok=True)
        image.save(thumbnail_path, "JPEG")

    def apply_terms(sequences: str, sequences_tmux: str, state_path: Path) -> None:
        state_path.parent.mkdir(parents=True, exist_ok=True)
        state_path.write_text(sequences, encoding="utf-8")

        pts_path = Path("/dev/pts")
        if not pts_path.exists():
            return

        O_NOCTTY = getattr(os, "O_NOCTTY", 0)

        for pt in pts_path.iterdir():
            if not pt.name.isdigit():
                continue
            try:
                fd = os.open(str(pt), os.O_WRONLY | os.O_NONBLOCK | O_NOCTTY)
                try:
                    os.write(fd, sequences_tmux.encode())
                    os.write(fd, sequences.encode())
                finally:
                    os.close(fd)
            except (PermissionError, OSError, BlockingIOError):
                pass

    def smart_mode(image_path: Path) -> str:
        is_dark = ""

        with Image.open(image_path) as img:
            img.thumbnail((1, 1), Image.LANCZOS)
            hct = Hct.from_int(argb_from_rgb(*img.getpixel((0, 0))))
            is_dark = "light" if hct.tone > 50 else "dark"

        return is_dark

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

        term = terminal_palette(colors, mode, variant)
        ctx.update(term)
        ctx["term"] = [term[f"term{i}"] for i in range(16)]

        seq = make_sequences(
            term=term,
            foreground=ctx["m3onSurface"],
            background=ctx["m3surface"],
        )
        ctx["sequences"] = seq
        ctx["sequences_tmux"] = tmux_wrap_sequences(seq)

        return ctx

    def make_sequences(
        *,
        term: dict[str, str],
        foreground: str,
        background: str,
    ) -> str:
        ESC = "\x1b"
        ST = ESC + "\\"

        parts: list[str] = []

        for i in range(16):
            parts.append(f"{ESC}]4;{i};{term[f'term{i}']}{ST}")

        parts.append(f"{ESC}]10;{foreground}{ST}")
        parts.append(f"{ESC}]11;{background}{ST}")

        return "".join(parts)

    def tmux_wrap_sequences(seq: str) -> str:
        ESC = "\x1b"
        return f"{ESC}Ptmux;{seq.replace(ESC, ESC+ESC)}{ESC}\\"

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

    def generate_color_scheme(seed: Hct, mode: str, scheme_class) -> dict[str, str]:

        is_dark = mode.lower() == "dark"

        scheme = scheme_class(
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
        with CONFIG.open() as f:
            config = json.load(f)

        scheme = scheme or config["colors"]["schemeType"]
        config_mode = config["general"]["color"]["mode"]
        smart = bool(config["general"]["color"].get("smart", False))
        scheme_class = get_scheme_class(scheme)

        if preset:
            seed = seed_from_preset(preset)
            effective_mode = mode or config_mode
            name, flavor = preset.split(":")
        else:
            image_path = image_path or Path(WALL_PATH)
            generate_thumbnail(image_path, str(THUMB_PATH))
            seed = seed_from_image(THUMB_PATH)
            name = "dynamic"
            flavor = "default"

            if smart:
                effective_mode = smart_mode(THUMB_PATH)
            elif mode is not None:
                effective_mode = mode
            else:
                effective_mode = config_mode

        colors = generate_color_scheme(seed, effective_mode, scheme_class)

        output_dict = {
            "name": name,
            "flavor": flavor,
            "mode": effective_mode,
            "variant": scheme,
            "colors": colors,
            "seed": seed.to_int()
        }

        if TEMPLATE_DIR is not None:
            wp = str(WALL_PATH)
            ctx = build_template_context(
                colors=colors,
                seed=seed,
                mode=effective_mode,
                wallpaper_path=wp,
                name=name,
                flavor=flavor,
                variant=scheme
            )

            rendered = render_all_templates(
                templates_dir=TEMPLATE_DIR,
                context=ctx,
            )

            apply_terms(ctx["sequences"], ctx["sequences_tmux"], SEQ_STATE)

            for p in rendered:
                print(f"rendered: {p}")

        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        with open(OUTPUT, "w") as f:
            json.dump(output_dict, f, indent=4)
    except Exception as e:
        print(f"Error: {e}")
        # with open(output, "w") as f:
        #     f.write(f"Error: {e}")
