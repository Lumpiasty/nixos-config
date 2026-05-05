{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.enablePcApps = lib.mkEnableOption "Enable desktop apps for this account";

  config = lib.mkIf (config.lumpiastyHome.enablePcApps && osConfig.lumpiasty.pc) {
    home.packages = with pkgs; [
      vesktop
      # Manual update, not yet in nixpkgs as for now
      (spotify.overrideAttrs (old: rec {
        version = "1.2.86.502.g8cd7fb22";
        rev = "94";
        src = fetchurl {
          name = "spotify-${version}-${rev}.snap";
          url = "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_${rev}.snap";
          hash = "sha256-XhwyaObck6viIvDRXEztlSLja5fsfw5HgHUUQzMehLI=";
        };
      }))
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