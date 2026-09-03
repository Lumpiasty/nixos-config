{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.macos = lib.mkEnableOption "Macos specific things";

  config = lib.mkIf config.lumpiastyHome.macos {
    targets.darwin.copyApps.enable = true;
    targets.darwin.linkApps.enable = false;
  };
}