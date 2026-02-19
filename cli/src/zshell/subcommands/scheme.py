from typing import Annotated, Optional
import typer
import json

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
    thumbnail_path: Optional[Path] = typer.Option(
        Path("thumb.jpg"), help="Path to temporary thumbnail (image mode)."),
    scheme: Optional[str] = typer.Option(
        "fruit-salad", help="Color scheme algorithm to use for image mode. Ignored in preset mode."),
    # preset inputs (optional - used for preset mode)
    preset: Optional[str] = typer.Option(
        None, help="Name of a premade scheme in this format: <preset_name>:<preset_flavor>"),
    mode: str = typer.Option(
        "dark", help="Mode of the preset scheme (dark or light)."),
    # output (required)
    output: Path = typer.Option(..., help="Output JSON path.")
):
    if preset is None and image_path is None:
        raise typer.BadParameter(
            "Either --image-path or --preset must be provided.")

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

    def generate_thumbnail(image_path, thumbnail_path, size=(128, 128)):
        thumbnail_file = Path(thumbnail_path)

        image = Image.open(image_path)
        image = image.convert("RGB")
        image.thumbnail(size, Image.NEAREST)

        thumbnail_file.parent.mkdir(parents=True, exist_ok=True)
        image.save(thumbnail_path, "JPEG")

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

        if is_dark:
            seed = Hct.from_hct(seed.hue, seed.chroma, min(seed.tone, 20))
        else:
            seed = Hct.from_hct(seed.hue, seed.chroma, max(seed.tone, 70))

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
        else:
            generate_thumbnail(image_path, str(thumbnail_path))
            seed = seed_from_image(thumbnail_path)
            colors = generate_color_scheme(seed, mode)
            name = "dynamic"
            flavor = "default"

        output_dict = {
            "name": name,
            "flavor": flavor,
            "mode": mode,
            "variant": scheme,
            "colors": colors
        }

        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w") as f:
            json.dump(output_dict, f, indent=4)
    except Exception as e:
        print(f"Error: {e}")
        # with open(output, "w") as f:
        #     f.write(f"Error: {e}")
