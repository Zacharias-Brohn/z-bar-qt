{
  rev,
  lib,
  stdenv,
  makeWrapper,
  makeFontsConf,
  app2unit,
  networkmanager,
  swappy,
  wl-clipboard,
  libqalculate,
  bash,
  material-symbols,
  rubik,
  nerd-fonts,
  qt6,
  quickshell,
  aubio,
  pipewire,
  cmake,
  ninja,
  pkg-config,
}:
let
  version = "1.0.0";

  runtimeDeps = [
    app2unit
    networkmanager
    swappy
    wl-clipboard
    libqalculate
    bash
  ];

  fontconfig = makeFontsConf {
    fontDirectories = [
      material-symbols
      rubik
      nerd-fonts.caskaydia-cove
    ];
  };

  cmakeBuildType = "RelWithDebInfo";

  cmakeVersionFlags = [
    (lib.cmakeFeature "VERSION" version)
    (lib.cmakeFeature "GIT_REVISION" rev)
    (lib.cmakeFeature "DISTRIBUTOR" "nix-flake")
  ];

  plugin = stdenv.mkDerivation {
    inherit cmakeBuildType;
    name = "zshell-qml-plugin";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.union ./../CMakeLists.txt ./../Plugins;
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];
    buildInputs = [
      qt6.qtbase
      qt6.qtdeclarative
      libqalculate
      pipewire
      aubio
    ];

    dontWrapQtApps = true;
    cmakeFlags = [
      (lib.cmakeFeature "ENABLE_MODULES" "plugin")
      (lib.cmakeFeature "INSTALL_QMLDIR" qt6.qtbase.qtQmlPrefix)
    ]
    ++ cmakeVersionFlags;
  };
in
stdenv.mkDerivation {
  inherit version cmakeBuildType;
  pname = "zshell";
  src = ./..;

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    quickshell
    plugin
    qt6.qtbase
    qt6.qtwayland
  ];
  propagatedBuildInputs = runtimeDeps;

  cmakeFlags = [
    (lib.cmakeFeature "ENABLE_MODULES" "shell")
    (lib.cmakeFeature "INSTALL_QSCONFDIR" "${placeholder "out"}/share/ZShell")
  ]
  ++ cmakeVersionFlags;

  prePatch = ''
    substituteInPlace shell.qml \
      --replace-fail 'ShellRoot {' 'ShellRoot {  settings.watchFiles: false'
  '';

  postInstall = ''
        makeWrapper ${quickshell}/bin/qs $out/bin/zshell \
        	--prefix PATH : "${lib.makeBinPath runtimeDeps}" \
        	--set FONTCONFIG_FILE "${fontconfig}" \
        	--add-flags "-p $out/share/ZShell"

    	echo "$out"
        mkdir -p $out/lib
  '';

  passthru = {
    inherit plugin;
  };

  meta = {
    description = "A very segsy desktop shell";
    homepage = "https://github.com/Zacharias-Brohn/z-bar-qt";
    license = lib.licenses.gpl3Only;
    mainProgram = "zshell";
  };
}
