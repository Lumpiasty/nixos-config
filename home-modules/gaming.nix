{ config, lib, pkgs, osConfig, ... }:

let
  # https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf
  mangohudConfig = pkgs.writeText "mangohud.conf" ''
    fps_limit=0,60,90,120,240
    show_fps_limit
  '';

in {
  options.lumpiastyHome.gaming = lib.mkEnableOption "Gaming account";

  config = lib.mkIf config.lumpiastyHome.gaming {
    xdg.configFile."MangoHud/MangoHud.conf".source = mangohudConfig;

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