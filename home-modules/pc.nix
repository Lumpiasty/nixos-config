{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.enablePcApps = lib.mkEnableOption "Enable desktop apps for this account";

  config = lib.mkIf (config.lumpiastyHome.enablePcApps && osConfig.lumpiasty.pc) {
    home.packages = with pkgs; [
      vesktop
      # Manual update, not yet in nixpkgs as for now
      spotify
      inkscape
      qtpass
      signal-desktop
      transmission_4-qt
      thunderbird
      pwgen
      siyuan
    ];
    programs.librewolf.enable = true;

    # services.flatpak.remotes = [{
    #   name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    # }];
    # services.flatpak.packages = [
    #   # "org.onlyoffice.desktopeditors"
    # ];

    # Vesktop settings
    # Nope, TODO
    # home.file.vesktop = {
    #   enable = true;
    #   executable = false;
    #   source = ./Vencord/settings.json;
    #   target = ".config/Vencord/settings.json";
    # };
    # home.file.vesktopPlugins = {
    #   enable = true;
    #   executable = false;
    #   source = ./Vencord/settings/settings.json;
    #   target = ".config/vesktop/settings/settings.json";
    # };
  };
}