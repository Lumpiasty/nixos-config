{ lib, pkgs, ... }:

{
  # Identity
  networking.hostName = "x260"; # Define your hostname.

  # Hardware
  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swap
  zramSwap.enable = true;

  # Storage
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/700cbbf6-b2c6-4bff-9d5f-374e39874a03";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E82E-7726";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # Config modules
  lumpiasty = {
    pc = true;
    enablePlasma = true;
    intelCpu = true;
    noMitigations = true;
    enablePulseaudio = true;
    sshd = true;
    users.user = true;
    # users.drugi = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}