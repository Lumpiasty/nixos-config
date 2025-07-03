{ config, lib, pkgs, modulesPath, nix-flatpak, ... }:

let
  cfg = config.lumpiasty.users;
  mkHome = import ../../lib/mkHome.nix { lib = lib; nix-flatpak = nix-flatpak; };
  mkUser = import ../../lib/mkUser.nix { lib = lib; };
in
{
  options.lumpiasty.users = {
    user = lib.mkEnableOption "Create user \"user\"";
    drugi = lib.mkEnableOption "Create user \"drugi\"";
  };


  config = {
    # Docker rootless user service, only if pc
    # Unfortunately, not implemented in home-manager yet
    virtualisation.docker.rootless = {
      enable = config.lumpiasty.pc;
      setSocketVariable = true;
    };

    # Flatpak
    services.flatpak.enable = true;

    # Users
    users.mutableUsers = false;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # User user
    users.users.user = mkUser cfg.user ../../users/user/config.nix;
    home-manager.users.user = mkHome cfg.user ../../users/user/home.nix;

    # User drugi
    users.users.drugi = mkUser cfg.drugi ../../users/drugi/config.nix;
    home-manager.users.drugi = mkHome cfg.drugi ../../users/drugi/home.nix;
  };
}