from PIL import Image, ImageFilter
import argparse

def gen_blurred_image(input_image, output_path, blur_amount):
    img = Image.open(input_image)
    size = img.size
    img = img.resize((size[0] // 2, size[1] // 2), Image.NEAREST)

    img = img.filter(ImageFilter.GaussianBlur(blur_amount))
    # img = img.resize(size, Image.LANCZOS)

    img.save(output_path, "PNG")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a blurred lock screen background image.")
    parser.add_argument("--input_image", type=str)
    parser.add_argument("--output_path", type=str)
    parser.add_argument("--blur_amount", type=int)

    args = parser.parse_args()

    gen_blurred_image(args.input_image, args.output_path, args.blur_amount)
