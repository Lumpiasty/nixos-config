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

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
  ];

  # Makefile provided in repo is useless, hardcoded paths, overwriting it
  patchPhase = ''
    cat > Makefile <<EOF
    obj-m += acer-wmi-battery.o

    all:
    $(printf '\t')make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=\$(PWD) modules

    modules_install:
    $(printf '\t')make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=\$(PWD) modules_install
    EOF
  '';

  buildFlags = [ "all" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Acer WMI kernel module for battery charge limit";
    homepage = "https://github.com/frederik-h/acer-wmi-battery";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
