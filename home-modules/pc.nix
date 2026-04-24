{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.enablePcApps = lib.mkEnableOption "Enable desktop apps for this account";

  config = lib.mkIf (config.lumpiastyHome.enablePcApps && osConfig.lumpiasty.pc) {
    home.packages = with pkgs; [
      vesktop
      spotify
      pass-wayland
      teamspeak6-client
      easyeffects
      libreoffice-qt6-fresh
      vlc
      inkscape
      (qtpass.overrideAttrs (old: rec {
        version = "1.7.0";
        src = pkgs.fetchFromGitHub {
          owner = "IJHack";
          repo = "QtPass";
          tag = "v${version}";
          hash = "sha256-0qbKM24v7xRiuBEs+rHP2l1W8bCl7uJRc3jzpDdjp/c=";
        };
      }))
      signal-desktop
      transmission_4-qt6
      thunderbird
      pwgen
      siyuan
      gimp
      ventoy-full-qt
    ];
    programs.librewolf.enable = true;
    services.easyeffects.enable = true;

    programs.chromium.enable = true;
    programs.chromium.package = pkgs.ungoogled-chromium;

    services.flatpak.remotes = [{
      name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
    services.flatpak.packages = [
      # "org.onlyoffice.desktopeditors"
    ];

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