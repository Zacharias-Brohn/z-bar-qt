{
  python3,
}:
python3.pkgs.buildPythonApplication {
  pname = "zshell-cli";
  version = "0.1.0";
  src = ./cli/.;
  pyproject = true;

  build-system = with python3.pkgs; [
    hatch-vcs
    hatchling
  ];

  dependencies = with python3.pkgs; [
    materialyoucolor
    pillow
  ];

  pythonImportsCheck = [ "zshell" ];

  nativeBuildInputs = [ installShellFiles ];

  SETUPTOOLS_SCM_PRETEND_VERSION = 1;
}
