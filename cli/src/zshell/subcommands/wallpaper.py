import subprocess
import typer

from typing import Annotated
from PIL import Image, ImageFilter
from pathlib import Path

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def set(wallpaper: Path):
    subprocess.run(args + ["ipc"] + ["call"] +
                   ["wallpaper"] + ["set"] + [wallpaper], check=True)


@app.command()
def lockscreen(
        input_image: Annotated[
            Path,
            typer.Option(),
        ],
        output_path: Annotated[
            Path,
            typer.Option(),
        ],
        blur_amount: int = 20
):
    img = Image.open(input_image)
    size = img.size
    if (size[0] < 3840 or size[1] < 2160):
        img = img.resize((size[0] // 2, size[1] // 2), Image.NEAREST)
    else:
        img = img.resize((size[0] // 4, size[1] // 4), Image.NEAREST)

    img = img.filter(ImageFilter.GaussianBlur(blur_amount))

    img.save(output_path, "PNG")
