import json
import argparse
from pathlib import Path
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.hct.hct import Hct


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

    scheme = SchemeTonalSpot(
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


def main():
    parser = argparse.ArgumentParser(
        description="Generate color scheme from wallpaper image"
    )

    parser.add_argument(
        "--path",
        required=True,
        help="Path to the wallpaper image"
    )

    parser.add_argument(
        "--output",
        required=True,
        help="Path to save the color scheme JSON file"
    )

    parser.add_argument(
        "--thumbnail",
        required=True,
        help="Path to save the thumbnail image"
    )

    args = parser.parse_args()
    
    try:
        generate_thumbnail(args.path, str(args.thumbnail))
        generate_color_scheme(str(args.thumbnail), args.output)
    except Exception as e:
        print(f"Error: {e}")
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
