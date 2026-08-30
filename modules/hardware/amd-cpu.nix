{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkIf config.lumpiasty.amdCpu {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;
  };
}