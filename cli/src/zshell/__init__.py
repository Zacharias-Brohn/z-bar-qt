from __future__ import annotations
import typer
from zshell.subcommands import shell, scheme, screenshot, wallpaper

app = typer.Typer()

app.add_typer(shell.app, name="shell")
app.add_typer(scheme.app, name="scheme")
app.add_typer(screenshot.app, name="screenshot")
app.add_typer(wallpaper.app, name="wallpaper")


def main() -> None:
    app()
