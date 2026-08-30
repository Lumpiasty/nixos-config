{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkIf config.lumpiasty.intelCpu {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    # hardware.cpu.intel.updateMicrocode = true;
    boot.kernelModules = [ "kvm-intel" ];
  };
}