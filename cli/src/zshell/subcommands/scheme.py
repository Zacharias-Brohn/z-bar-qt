from typing import Annotated
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
    path: Annotated[
        Path,
        typer.Option(),
    ],
    output: Annotated[
        Path,
        typer.Option(),
    ],
    thumbnail: Annotated[
        Path,
        typer.Option(),
    ],
    scheme: Annotated[
        str,
        typer.Option()
    ]
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

    def int_to_hex(argb_int):
        return "#{:06X}".format(argb_int & 0xFFFFFF)

    try:
        generate_thumbnail(path, str(thumbnail))
        generate_color_scheme(str(thumbnail), output)
    except Exception as e:
        print(f"Error: {e}")
        with open(output, "w") as f:
            f.write(f"Error: {e}")
