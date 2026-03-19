{ config, lib, pkgs, modulesPath, ... }:

let 
  keepGenerations = if config.boot.lanzaboote.enable then
      config.boot.lanzaboote.configurationLimit
    else if config.boot.loader.systemd-boot.enable then 
      config.boot.loader.systemd-boot.configurationLimit
    else null;
in 
{
  nix = {
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
    settings.trusted-users = [ "root" "user" ];
  };

  # Clean up nix store from old configurations usinx nix-sweep
  services.nix-sweep = {
    enable = true;

    # Automatically determine configuration limit from bootloader
    keepMax = keepGenerations;
    keepMin = if keepGenerations != null then keepGenerations else 10;

    gc = true; # Run GC afterwards
  };

  services.peerix = {
    enable = true;
    trackerUrl = null;  # Use LAN mode instead of Iroh
  };
}