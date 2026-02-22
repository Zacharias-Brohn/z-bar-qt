import subprocess
import typer

args = ["qs", "-c", "zshell"]

app = typer.Typer()


@app.command()
def start():
    subprocess.run(args + ["ipc"] + ["call"] +
                   ["picker"] + ["open"], check=True)


@app.command()
def start_freeze():
    subprocess.run(args + ["ipc"] + ["call"] +
                   ["picker"] + ["openFreeze"], check=True)
