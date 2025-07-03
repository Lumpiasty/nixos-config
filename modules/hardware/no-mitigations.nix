{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.noMitigations = lib.mkEnableOption "Disable mitigations";

  config = lib.mkIf config.lumpiasty.noMitigations {
    boot.kernelParams = [
      "mitigations=off"
    ];
  };
}