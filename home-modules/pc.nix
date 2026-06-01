{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.enablePcApps = lib.mkEnableOption "Enable desktop apps for this account";

  config = lib.mkIf (config.lumpiastyHome.enablePcApps && osConfig.lumpiasty.pc) {
    home.packages = with pkgs; [
      vesktop
      # Manual update, not yet in nixpkgs as for now
      spotify
      pass-wayland
      teamspeak6-client
      easyeffects
      libreoffice-qt6-fresh
      vlc
      inkscape
      qtpass
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
    systemd.user.services.easyeffects.Service = lib.mkIf osConfig.lumpiasty.audioRt.cpuPartitioning {
      # Move easyeffects into audio.slice (defined in modules/desktop/audio-rt.nix)
      # which has AllowedCPUs=<audioCpus> — pins all DSP work to the reserved cores.
      Slice = "audio.slice";
    };

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