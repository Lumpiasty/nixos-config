{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.enablePcApps = lib.mkEnableOption "Enable desktop apps for this account";

  config = lib.mkIf (config.lumpiastyHome.enablePcApps && osConfig.lumpiasty.pc) {
    home.packages = with pkgs; [
      vesktop
      spotify
      pass
      teamspeak_client
      easyeffects
      prismlauncher
      libreoffice-qt6-fresh
      vlc
      inkscape
      # Working aroung bug of qtpass
      # https://github.com/IJHack/QtPass/issues/663
      (
        # https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
        runCommand "qtpass" {
          buildInputs = [ makeWrapper ];
        } ''
          mkdir $out
          # Link every top-level folder from pkgs.hello to our new target
          ln -s ${qtpass}/* $out
          # Except the bin folder
          rm $out/bin
          mkdir $out/bin
          # creating a wrapper
          makeWrapper ${qtpass}/bin/qtpass $out/bin/qtpass \
            --set QT_QPA_PLATFORM xcb
        ''
      )
    ];
    programs.librewolf.enable = true;
    services.easyeffects.enable = true;

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