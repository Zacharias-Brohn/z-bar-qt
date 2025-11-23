{
  lib,
  stdenv,
  makeWrapper,
  makeFontsConf,
  app2unit,
  swappy,
  libqalculate,
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
  debug ? false,
  withCli ? false,
  extraRuntimeDeps ? [],
}: let
  version = "1.0.0";

  runtimeDeps =
    [
      app2unit
      swappy
      wl-clipboard
      libqalculate
      bash
      hyprland
    ];

  fontconfig = makeFontsConf {
    fontDirectories = [material-symbols rubik nerd-fonts.caskaydia-cove];
  };

  plugin = stdenv.mkDerivation {
    inherit cmakeBuildType;
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
    inherit version cmakeBuildType;
    pname = "zshell";
    src = ./..;

    nativeBuildInputs = [cmake ninja makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [quickshell plugin qt6.qtbase];
    propagatedBuildInputs = runtimeDeps;

    cmakeFlags =
      [
        (lib.cmakeFeature "ENABLE_MODULES" "shell")
        (lib.cmakeFeature "INSTALL_QSCONFDIR" "${placeholder "out"}/share/zshell")
      ];

    dontStrip = debug;

    prePatch = ''
      substituteInPlace assets/pam.d/fprint \
        --replace-fail pam_fprintd.so /run/current-system/sw/lib/security/pam_fprintd.so
      substituteInPlace shell.qml \
        --replace-fail 'ShellRoot {' 'ShellRoot {  settings.watchFiles: false'
    '';

    postInstall = ''
      mkdir -p $out/lib
      ln -s ${extras}/lib/* $out/lib/
    '';

    passthru = {
      inherit plugin;
    };
  }
