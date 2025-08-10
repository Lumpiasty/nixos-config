# Custom module for Acer WMI features, like battery charge limit
{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel
}:

stdenv.mkDerivation {
  pname = "acer-wmi-battery";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "frederik-h";
    repo = "acer-wmi-battery";
    rev = "0889d3ea54655eaa88de552b334911ce7375952f";
    sha256 = "sha256-mI6Ob9BmNfwqT3nndWf3jkz8f7tV10odkTnfApsNo+A=";
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

  patchPhase = ''
    cat > Kbuild <<EOF
    obj-m := acer-wmi-battery.o
    EOF
  '';

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Acer WMI kernel module for battery charge limit";
    homepage = "https://github.com/frederik-h/acer-wmi-battery";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
