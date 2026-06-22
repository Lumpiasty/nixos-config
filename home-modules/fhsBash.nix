{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.fhs = lib.mkEnableOption "FHS bash wrapper";

  config = lib.mkIf (config.lumpiastyHome.fhs) {
    home.packages = [
      (pkgs.buildFHSEnv {
        name = "fhs";
        targetPkgs = p: [];
        runScript = "bash";
      })
    ];
  };
}
