{ config, lib, pkgs, modulesPath, ... }:
{
  options.lumpiasty.gaming = lib.mkEnableOption "Enable options specific to gaming computers";

  config = lib.mkIf config.lumpiasty.gaming {
    # https://github.com/NixOS/nixpkgs/blob/10e687235226880ed5e9f33f1ffa71fe60f2638a/nixos/modules/programs/steam.nix
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.pulseaudio.support32Bit = config.services.pulseaudio.enable;
    services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;
    programs.gamemode = {
      enable = true;
      settings = {
        custom = {
          start = toString (pkgs.writeScript "gamemode-start" ''
            ${pkgs.libnotify}/bin/notify-send -a 'GameMode' 'GameMode started'
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
          '');
          end = toString (pkgs.writeScript "gamemode-end" ''
            ${pkgs.libnotify}/bin/notify-send -a 'GameMode' 'GameMode ended'
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
          '');
        };
      };
    };
    users.users = {
      user = lib.mkIf config.lumpiasty.users.user {
        extraGroups = ["gamemode"];
      };
    };

    services.scx = {
      enable = true;
      scheduler = "scx_cosmos";
    };
  };
}