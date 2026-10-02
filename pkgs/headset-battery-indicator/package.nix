{
  lib,
  python3Packages,
  fetchFromGitHub,
  qt6,
  headsetcontrol,
  xdg-utils,
}:

python3Packages.buildPythonApplication rec {
  pname = "headset-battery-indicator";
  version = "2.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ruflas";
    repo = "headset-battery-indicator";
    tag = "v${version}";
    hash = "sha256-e9o8ECUjmu+G8OgEKjtshs1mFz4EXh30xrwL5Fx3lcQ=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = [ python3Packages.pyside6 ];

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [ qt6.qtbase qt6.qtwayland ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook pytest-qt ];
  preCheck = ''
    export QT_QPA_PLATFORM=offscreen
    export HOME=$(mktemp -d)
  '';

  postInstall = ''
    install -Dm644 headset-battery-indicator.png \
      $out/share/icons/hicolor/512x512/apps/headset-battery-indicator.png
    install -Dm644 headset-battery-indicator.desktop \
      $out/share/applications/headset-battery-indicator.desktop
  '';

  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ headsetcontrol xdg-utils ]}
    )
  '';

  pythonImportsCheck = [ "headset_battery_indicator" ];

  meta = {
    description = "Tray indicator for wireless headset battery level, based on HeadsetControl";
    homepage = "https://github.com/ruflas/headset-battery-indicator";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "headset-battery-indicator";
  };
}
