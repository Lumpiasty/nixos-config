{ config, lib, pkgs, osConfig, ... }:

let
  # https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf
  mangohudConfig = pkgs.writeText "mangohud.conf" ''
    fps_limit=0,60,90,120,240
    show_fps_limit
  '';

  mangohudWrapped = (pkgs.runCommand
    "mangohud"
    { nativeBuildInputs = [ pkgs.makeWrapper ]; }
    "makeWrapper ${pkgs.mangohud}/bin/mangohud $out/bin/mangohud --set MANGOHUD_CONFIGFILE ${mangohudConfig}"
  );
in {
  options.lumpiastyHome.gaming = lib.mkEnableOption "Gaming account";

  config = lib.mkIf config.lumpiastyHome.gaming {
    programs.lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohudWrapped
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
        extraPkgs = pkgs': with pkgs'; [ mangohudWrapped gamescope ];
      })
    ];
  };
}