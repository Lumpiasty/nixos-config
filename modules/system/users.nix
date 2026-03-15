{ config, lib, pkgs, modulesPath, nix-flatpak, plasma-manager, ... }:

let
  cfg = config.lumpiasty.users;
  mkHome = import ../../lib/mkHome.nix {
    inherit lib;
    inherit nix-flatpak;
    inherit plasma-manager;
  };
  mkUser = import ../../lib/mkUser.nix { inherit lib; };
in
{
  options.lumpiasty.users = {
    user = lib.mkEnableOption "Create user \"user\"";
    drugi = lib.mkEnableOption "Create user \"drugi\"";
  };


  config = {
    # Install system-wide docker because rootless causes issues with binfmt
    virtualisation.docker.enable = config.lumpiasty.pc;

    # Binfmt for aarch64 emulation
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.binfmt.preferStaticEmulators = true;
    # Pass the binary to the interpreter as an open file descriptor, instead of a path.
    # Fixes issue inside containers.
    boot.binfmt.registrations.aarch64-linux.openBinary = true;
    boot.binfmt.registrations.aarch64-linux.fixBinary = true;

    # Libvirt
    virtualisation.libvirtd = lib.mkIf config.lumpiasty.pc {
      enable = true;
      # Enable TPM emulation
      # install pkgs.swtpm system-wide for use in virt-manager (optional)
      qemu.swtpm.enable = true;
    };

    # Enable USB redirection (optional)
    virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages = lib.mkIf config.lumpiasty.pc (with pkgs; [
      dnsmasq # Needed for libvirt networking
    ]);

    # GUI for managing virtual machines
    programs.virt-manager.enable = true;

    services.transmission = {
      enable = config.lumpiasty.pc && (config.lumpiasty.gaming == false);
      package = pkgs.transmission_4; # For some reason 3.x is still default
      user = "user";
      group = "users";
      settings.download-dir = "/home/user/Downloads";
      settings.incomplete-dir-enabled = false;
      openPeerPorts = true;
    };

    # Flatpak
    services.flatpak.enable = true;

    # Users
    users.mutableUsers = false;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # User user
    users.users.user = lib.mkMerge [
      (mkUser cfg.user ../../users/user/config.nix)
      {
        extraGroups = lib.mkIf config.lumpiasty.pc [ "docker" "libvirtd" ];
      }
    ];
    home-manager.users.user = mkHome cfg.user ../../users/user/home.nix;

    # User drugi
    users.users.drugi = mkUser cfg.drugi ../../users/drugi/config.nix;
    home-manager.users.drugi = mkHome cfg.drugi ../../users/drugi/home.nix;
  };
}