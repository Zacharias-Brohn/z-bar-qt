import subprocess
import typer

args = ["qs", "-c", "zshell"]

app = typer.Typer()

@app.command()
def kill():
    subprocess.run(args + ["kill"], check=True)

@app.command()
def start(no_daemon: bool = False):
    subprocess.run(args + ([] if no_daemon else ["-d"]), check=True)

@app.command()
def show():
    subprocess.run(args + ["ipc"] + ["show"], check=True)

@app.command()
def log():
    subprocess.run(args + ["log"], check=True)

@app.command()
def lock():
    subprocess.run(args + ["ipc"] + ["call"] + ["lock"] + ["lock"], check=True)
