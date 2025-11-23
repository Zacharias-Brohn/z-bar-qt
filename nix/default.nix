{
  rev,
  lib,
  stdenv,
  makeWrapper,
  makeFontsConf,
  app2unit,
  lm_sensors,
  swappy,
  wl-clipboard,
  libqalculate,
  bash,
  hyprland,
  material-symbols,
  rubik,
  nerd-fonts,
  qt6,
  quickshell,
  aubio,
  fftw,
  pipewire,
  xkeyboard-config,
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
      ddcutil
      brightnessctl
      app2unit
      networkmanager
      lm_sensors
      swappy
      wl-clipboard
      libqalculate
      bash
      hyprland
    ]
    ++ extraRuntimeDeps

  fontconfig = makeFontsConf {
    fontDirectories = [material-symbols rubik nerd-fonts.caskaydia-cove];
  };

  cmakeBuildType =
    if debug
    then "Debug"
    else "RelWithDebInfo";

  plugin = stdenv.mkDerivation {
    inherit cmakeBuildType;
    name = "zshell-qml-plugin${lib.optionalString debug "-debug"}";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.union ./../CMakeLists.txt ./../Plugins;
    };

    nativeBuildInputs = [cmake ninja pkg-config];
    buildInputs = [qt6.qtbase qt6.qtdeclarative libqalculate pipewire aubio libcava fftw];

    dontWrapQtApps = true;
  };
in
  stdenv.mkDerivation {
    inherit version cmakeBuildType;
    pname = "zshell${lib.optionalString debug "-debug"}";
    src = ./..;

    nativeBuildInputs = [cmake ninja makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [quickshell extras plugin xkeyboard-config qt6.qtbase];
    propagatedBuildInputs = runtimeDeps;

    cmakeFlags =
      [
        (lib.cmakeFeature "ENABLE_MODULES" "shell")
        (lib.cmakeFeature "INSTALL_QSCONFDIR" "${placeholder "out"}/share/zshell")
      ]
      ++ cmakeVersionFlags;

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
