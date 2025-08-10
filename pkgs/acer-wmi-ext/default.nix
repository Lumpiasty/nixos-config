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
    owner = "TenSeventy7";
    repo = "acer-wmi-ext";
    rev = "78aaf9392e1fbdd62c3ec9944e9615505485ec04";
    sha256 = "sha256-AmhBnZiy7llYqHB9gD6T7lK4L2qhtl5pBWAf+H+V8hE=";
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
    # Add support for Acer Swift 14 (SFG14-63) model
    # Using values found by playing with performance settings in acer's software on windows
    # https://github.com/hirschmann/nbfc/wiki/Probe-the-EC's-registers
    # Also, disable USB control because not sure, need to verify
    patch -p1 < ${./sfg14-63.patch}

    # Create Kbuild file for module
    cat > Kbuild <<EOF
    obj-m := acer-wmi-ext.o
    EOF
  '';

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
