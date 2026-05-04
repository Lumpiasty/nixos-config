{ config, lib, pkgs, modulesPath, ... }:

let 
  keepGenerations = if config.boot.lanzaboote.enable then
      config.boot.lanzaboote.configurationLimit
    else if config.boot.loader.systemd-boot.enable then 
      config.boot.loader.systemd-boot.configurationLimit
    else null;

  # NixBSD builder VM SSH key (needs to be readable by root/nix-daemon)
  builderKeyDir = "/etc/nix/builder-keys";
in 
{
  nix = {
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
    settings.trusted-users = [ "root" "user" ];

    # FreeBSD remote builder VM (NixBSD)
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "192.168.122.100";
        system = "x86_64-freebsd";
        sshUser = "root";
        sshKey = "${builderKeyDir}/nixbsd-builder";
        maxJobs = 8;
        speedFactor = 1;
        supportedFeatures = [ "big-parallel" ];
      }
    ];
    settings.builders-use-substitutes = true;
  };

  # Install the builder SSH key where root/nix-daemon can read it
  system.activationScripts.nixbsd-builder-key = ''
    mkdir -p ${builderKeyDir}
    cp /home/user/Projects/nixbsd-flake/keys/builder ${builderKeyDir}/nixbsd-builder
    chmod 600 ${builderKeyDir}/nixbsd-builder
    chown root:root ${builderKeyDir}/nixbsd-builder
  '';

  # Skip host key checking for the local builder VM (keys change on rebuild)
  programs.ssh.extraConfig = ''
    Host 192.168.122.100
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
      LogLevel ERROR
  '';

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