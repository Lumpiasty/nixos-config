{ config, lib, pkgs, osConfig, ... }:

let
  # https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf
  mangohudConfig = pkgs.writeText "mangohud.conf" ''
    fps_limit=0,60,90,120,240
    preset=3,5
  '';

  mangohudPresets = pkgs.writeText "mangohud-preset.conf" ''
    [preset 5]
    gpu_stats
    gpu_temp
    gpu_core_clock
    gpu_power

    cpu_stats
    cpu_temp
    cpu_mhz
    cpu_power

    vram
    gpu_mem_clock

    ram
    swap
    
    battery
    battery_watt
    fps
    frametime
    frame_timing
    show_fps_limit
    network

    io_read
    io_write
  '';

in {
  options.lumpiastyHome.gaming = lib.mkEnableOption "Gaming account";

  config = lib.mkIf config.lumpiastyHome.gaming {
    xdg.configFile."MangoHud/MangoHud.conf".source = mangohudConfig;
    xdg.configFile."MangoHud/presets.conf".source = mangohudPresets;

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