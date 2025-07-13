{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.gaming = lib.mkEnableOption "Gaming account";

  config = lib.mkIf config.lumpiastyHome.gaming {
    programs.lutris = {
      enable = true;
      steamPackage = pkgs.steam;
    };
  };
}