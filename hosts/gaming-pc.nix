{ lib, pkgs, ... }:

{
  # Identity
  networking.hostName = "gaming-pc"; # Define your hostname.
  networking.hostId = "fc9583ce";

  # Hardware
  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  # boot.loader.systemd-boot = {
  #   enable = true;
  #   graceful = true;
  #   windows = {
  #       "windows" =
  #         let
  #           # To determine the name of the windows boot drive, boot into edk2 first, then run
  #           # `map -c` to get drive aliases, and try out running `FS1:`, then `ls EFI` to check
  #           # which alias corresponds to which EFI partition.
  #           boot-drive = "FS0";
  #         in
  #         {
  #           title = "Windows";
  #           efiDeviceHandle = boot-drive;
  #           sortKey = "y_windows";
  #         };
  #     };
  #   edk2-uefi-shell.enable = true;
  #   edk2-uefi-shell.sortKey = "z_edk2";
  #   # Limiting number of generations to prevent ESP from filling
  #   configurationLimit = 3;
  # };

  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 3;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  # Storage
  fileSystems = 
    let
      rootfs = "/dev/disk/by-uuid/c79f016c-b61b-4d99-93fc-fc38978bef0d";
    in {
      "/" =
        {
          device = rootfs;
          fsType = "btrfs";
          options = [ "subvol=/rootfs" "compress-force=zstd" ];
        };
      "/nix" =
        {
          device = rootfs;
          fsType = "btrfs";
          options = [ "subvol=/nix" "compress-force=zstd" "noatime" ];
        };
      "/home" =
        { 
          device = rootfs;
          fsType = "btrfs";
          options = [ "subvol=/home" "compress-force=zstd" ];
        };

      "/boot" =
        { device = "/dev/disk/by-uuid/3C56-F3E7";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };

      "/var/games" = 
        {
          device = "/dev/disk/by-uuid/8A3094A230949733"; # "Shared" NTFS partition
          fsType = "ntfs-3g";
          options = [
            "uid=1000" "gid=100" # My user account
            "nofail" # Don't fail boot if failed to mount because windows left it dirty
          ];
        };
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
    gaming = true;
    # users.drugi = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
    };
  };
  services.transmission.enable = lib.mkForce false;

  nix.settings.system-features = [ "gccarch-haswell" ];

  # nixpkgs.hostPlatform = {
  #   system = "x86_64-linux";
  #   gcc.arch = "haswell";
  #   gcc.tune = "haswell";
  # };

  # nixpkgs.overrides = [(self: super: {
  #   assimp
  # })];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
