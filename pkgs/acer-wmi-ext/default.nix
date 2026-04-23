# Custom module for Acer WMI features, like battery charge limit and fan control
{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel
}:

stdenv.mkDerivation {
  pname = "acer-wmi-ext";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "Lumpiasty";
    repo = "acer-wmi-ext";
    rev = "71bc84f4729eb53e7786aaed37957c6d91ce0cfd";
    sha256 = "sha256-eMKEVgEFaBB1oDL5mlmnJyEj24jzi8HsISl3cCzstD8=";
  };

  nativeBuildInputs = [ kernel.moduleBuildDependencies ];

  # Makefile provided in repo is useless, hardcoded paths, not using it

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';

  makeFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Acer WMI kernel module for battery charge limit and fan control";
    homepage = "https://github.com/TenSeventy7/acer-wmi-ext";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
