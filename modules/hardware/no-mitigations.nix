{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkIf config.lumpiasty.noMitigations {
    boot.kernelParams = [
      "mitigations=off"
    ];
  };
}