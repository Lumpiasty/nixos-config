{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.linux = lib.mkEnableOption "Linux specific things";
  config = lib.mkIf config.lumpiastyHome.linux {
    services.easyeffects.enable = true;
    systemd.user.services.easyeffects.Service = lib.mkIf osConfig.lumpiasty.audioRt.cpuPartitioning {
      # Move easyeffects into audio.slice (defined in modules/desktop/audio-rt.nix)
      # which has AllowedCPUs=<audioCpus> — pins all DSP work to the reserved cores.
      Slice = "audio.slice";
    };

    programs.chromium.enable = true;
    programs.chromium.package = pkgs.ungoogled-chromium;

    home.packages = with pkgs; (lib.optionals config.lumpiastyHome.dev [
      wl-clipboard
      traceroute
      amdgpu_top
    ] ++ lib.optionals config.lumpiastyHome.linux [
      pass-wayland
      libreoffice-qt-stable
      vlc
      gimp
      ventoy-full-qt
      teamspeak6-client
    ]);
  };
}