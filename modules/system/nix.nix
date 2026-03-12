{ config, lib, pkgs, modulesPath, ... }:

{
  nix = {
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
    settings.trusted-users = [ "root" "user" ];
    gc.automatic = true;
  };
}