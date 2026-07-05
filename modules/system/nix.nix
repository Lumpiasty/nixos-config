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
    
    # Use an empty string (not null) to use the modern unified app 
    # but with the internet tracker internally disabled.
    trackerUrl = "''"; 
    
    # Explicitly enable UDP broadcast discovery for your local network
    lanDiscovery = true; 
    
    # Disable the upstream cache.nixos.org checks so you can share ALL packages
    noFilter = true;
    noVerify = true; 
    
    # Configure signing so Nix doesn't reject your custom unsigned packages
    privateKeyFile = "/etc/cache-priv-key.pem";
    
    # Add the public key contents from `cache-pub-key.pem`
    # (If you used different keys on each machine, you can pass a list of strings
    # directly to nix.settings.extra-trusted-public-keys instead)
    publicKey = "my-lan-cache:SVN4NaqHJKxdAbWZ6wUtklmKkBUrACPg8oihH/mlp4Y="; 
  };
}