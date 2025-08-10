{ lib, pkgs, ... }:

rec {
  # Identity
  networking.hostName = "acer"; # Define your hostname.
  networking.hostId = "fc9583ce";

  # Hardware
  hardware.enableRedistributableFirmware = true;
  services.hardware.bolt.enable = true;
  hardware.bluetooth.enable = true;


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  # Storage
  fileSystems."/" =
    { 
      device = "acer-ssd/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/nix" =
    { 
      device = "acer-ssd/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/var" =
    { 
      device = "acer-ssd/var";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/home" =
    { 
      device = "acer-ssd/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/72EF-7CD3";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # Config modules
  lumpiasty = {
    pc = true;
    enablePlasma = true;
    intelCpu = false;
    noMitigations = false;
    enablePulseaudio = true;
    sshd = true;
    users.user = true;
    # users.drugi = true;
    touchPad = {
      enable = true;
      name = "PIXA3848:01 093A:3848 Touchpad";
      vendorId = "2362";
      productId = "14408";
      disableWhileTyping = false;
      scrollSpeed = 0.5;
      naturalScroll = false;
      pointerSpeed = 0.2;
      accelerationProfile = "default";
    };
    laptop = true;
    gaming = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
    };
  };
  
  # For dev vm stuff
  networking.firewall.trustedInterfaces = [ "br0" ];

  # Battery driver
  boot.extraModulePackages = [
    # Super ugly hack, for some reason it's not included in pkgs.linuxKernel.packages.linux_6_12
    # Despite being in overlays, something's not working
    (pkgs.linuxPackages.acer-wmi-ext.override {
      kernel = boot.kernelPackages.kernel;
    })
  ];
  boot.kernelModules = [ "acer-wmi-ext" ];
    

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}