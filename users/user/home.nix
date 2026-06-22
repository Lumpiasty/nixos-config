{ config, pkgs, osConfig, ... }:

{
  home.username = "user";

  lumpiastyHome = {
    gpg = osConfig.lumpiasty.pc;
    enablePcApps = osConfig.lumpiasty.pc;
    dev = osConfig.lumpiasty.pc;
    gaming = osConfig.lumpiasty.gaming;
    fhs = osConfig.lumpiasty.pc;
  };

  home.stateVersion = "24.05";
}