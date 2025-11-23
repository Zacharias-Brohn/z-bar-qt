{
  rev,
  lib,
  stdenv,
  makeWrapper,
  makeFontsConf,
  app2unit,
  swappy,
  bash,
  hyprland,
  material-symbols,
  rubik,
  nerd-fonts,
  qt6,
  quickshell,
  pipewire,
  cmake,
  ninja,
  pkg-config,
}: let
  version = "1.0.0";

  runtimeDeps =
    [
      app2unit
      swappy
      bash
      hyprland
    ];

  fontconfig = makeFontsConf {
    fontDirectories = [material-symbols rubik nerd-fonts.caskaydia-cove];
  };

  plugin = stdenv.mkDerivation {
    name = "zshell-qml-plugin";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.union ./../CMakeLists.txt ./../Plugins;
    };

    nativeBuildInputs = [cmake ninja pkg-config];
    buildInputs = [qt6.qtbase qt6.qtdeclarative libqalculate pipewire];

    dontWrapQtApps = true;
  };
in
  stdenv.mkDerivation {
    pname = "zshell";
    src = ./..;

    nativeBuildInputs = [cmake ninja makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [quickshell plugin qt6.qtbase];
    propagatedBuildInputs = runtimeDeps;

    cmakeFlags =
      [
        (lib.cmakeFeature "INSTALL_QSCONFDIR" "${placeholder "out"}/share/zshell")
      ];

    dontStrip = debug;

    passthru = {
      inherit plugin;
    };
  }
