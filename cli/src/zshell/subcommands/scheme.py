from typing import Annotated, Optional
import typer
import json

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
        None, help="Name of a premade scheme (preset)."),
    flavour: str = typer.Option("default", help="Flavor of the preset scheme."),
    mode: str = typer.Option(
        "dark", help="Mode of the preset scheme (dark or light)."),
    # output (required)
    output: Path = typer.Option(..., help="Output JSON path.")
):
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

    def normalize_hex(s: str) -> str:
        # Accepts "6a73ac", "#6a73ac", "B5CCBA" and returns "#B5CCBA"
        s = s.strip()
        if s.startswith("#"):
            s = s[1:]
        # If the value contains alpha (8 chars), drop alpha and keep RGB (last 6).
        if len(s) == 8:
            s = s[2:]  # assume AARRGGBB -> drop AA
        if len(s) != 6:
            raise ValueError(
                f"Invalid hex color '{s}' (expected 6 hex digits, optionally prefixed with '#').")
        return f"#{s.upper()}"

    def parse_preset_file(file_path: Path) -> dict:
        """
        Parse a preset scheme file with lines like:
          primary_paletteKeyColor 6a73ac
          background 131317
          onBackground e4e1e7
        Returns a dict mapping key -> "#RRGGBB"
        """
        mapping = {}
        with file_path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split()
                if len(parts) < 2:
                    # ignore malformed lines
                    continue
                key = parts[0].strip()
                value = parts[1].strip()
                try:
                    mapping[key] = normalize_hex(value)
                except ValueError:
                    # skip invalid hex but log to stdout
                    print(
                        f"Warning: skipping invalid color value for '{key}': {value}")
        return mapping

    def generate_thumbnail(image_path, thumbnail_path, size=(128, 128)):
        thumbnail_file = Path(thumbnail_path)

        image = Image.open(image_path)
        image = image.convert("RGB")
        image.thumbnail(size, Image.NEAREST)

        thumbnail_file.parent.mkdir(parents=True, exist_ok=True)
        image.save(thumbnail_path, "JPEG")

    def generate_color_scheme(thumbnail_path, output_path):
        image = Image.open(thumbnail_path)
        pixel_len = image.width * image.height
        image_data = image.getdata()

        quality = 1
        pixel_array = [image_data[_] for _ in range(0, pixel_len, quality)]

        result = QuantizeCelebi(pixel_array, 128)
        score = Score.score(result)[0]

        scheme = Scheme(
            Hct.from_int(score),
            True,
            0.0
        )

        color_dict = {}
        for color in vars(MaterialDynamicColors).keys():
            color_name = getattr(MaterialDynamicColors, color)
            if hasattr(color_name, "get_hct"):
                color_int = color_name.get_hct(scheme).to_int()
                color_dict[color] = int_to_hex(color_int)

        output_dict = {
            "name": "dynamic",
            "flavour": "default",
            "mode": "dark",
            "variant": "tonalspot",
            "colors": color_dict
        }

        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, "w") as f:
            json.dump(output_dict, f, indent=4)

    def generate_color_scheme_from_preset(preset_mapping: dict, output_path: Path, preset_name: str, flavour: str):
        """
        Build JSON output using keys from the preset file.
        Any keys in preset_mapping are included verbatim in the "colors" object.
        """
        color_dict = {}
        for k, v in preset_mapping.items():
            color_dict[k] = v  # v already normalized to "#RRGGBB"

        output_dict = {
            "name": preset_name,
            "flavour": flavour,
            "mode": mode,      # could be made configurable / auto-detected
            "variant": scheme,
            "colors": color_dict
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with output_path.open("w", encoding="utf-8") as f:
            json.dump(output_dict, f, indent=4)

    def int_to_hex(argb_int):
        return "#{:06X}".format(argb_int & 0xFFFFFF)

    try:
        if preset:
            # try local presets directory: presets/<preset>/<flavour>.txt or presets/<preset>-<flavour>.txt
            base1 = Path("zshell") / "assets" / "schemes" / \
                preset / flavour / f"{mode}.txt"
            if base1.exists():
                preset_path = base1
            else:
                raise FileNotFoundError(
                    f"Preset file not found. Looked for: {base1.resolve()}. "
                    "You can also pass --preset-file <path> directly."
                )

            mapping = parse_preset_file(preset_path)
            generate_color_scheme_from_preset(
                mapping, output, preset or preset_path.stem, flavour)
            typer.echo(f"Wrote preset-based scheme to {output}")
            raise typer.Exit()

        generate_thumbnail(image_path, str(thumbnail_path))
        generate_color_scheme(str(thumbnail_path), output)
    except Exception as e:
        print(f"Error: {e}")
        # with open(output, "w") as f:
        #     f.write(f"Error: {e}")
