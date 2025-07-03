{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.intelCpu = lib.mkEnableOption "Enable intel CPU";

  config = lib.mkIf config.lumpiasty.intelCpu {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    # hardware.cpu.intel.updateMicrocode = true;
    boot.kernelModules = [ "kvm-intel" ];
  };
}