from PIL import Image, ImageFilter
import argparse

def gen_blurred_image(input_image, output_path):
    img = Image.open(input_image)

    img = img.filter(ImageFilter.GaussianBlur(40))

    img.save(output_path, "PNG")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a blurred lock screen background image.")
    parser.add_argument("--input_image", type=str)
    parser.add_argument("--output_path", type=str)

    args = parser.parse_args()

    gen_blurred_image(args.input_image, args.output_path)
