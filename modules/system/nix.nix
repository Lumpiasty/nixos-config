{ config, lib, pkgs, modulesPath, ... }:

{
  nix = {
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
  };
}