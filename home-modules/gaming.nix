{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.gaming = lib.mkEnableOption "Gaming account";

  config = lib.mkIf config.lumpiastyHome.gaming {
    programs.lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
        gamescope
      ];
    };
    home.packages = with pkgs; [
      (prismlauncher.overrideAttrs (final: prev: {
        qtWrapperArgs = prev.qtWrapperArgs ++ [
          "--prefix XDG_DATA_DIRS : ${mangohud}/share"
        ];
      }))
      (steam.override {
        extraPkgs = pkgs': with pkgs'; [ mangohud gamescope ];
      })
    ];
  };
}