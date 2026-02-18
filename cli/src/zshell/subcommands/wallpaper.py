import subprocess
import typer

from pathlib import Path

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def set(wallpaper: Path):
    subprocess.run(args + ["ipc"] + ["call"] +
                   ["wallpaper"] + ["set"] + [wallpaper], check=True)
