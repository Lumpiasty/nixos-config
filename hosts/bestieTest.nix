{ config, pkgs, lib, ... }: {
  nixpkgs.hostPlatform = "x86_64-freebsd";
  nixpkgs.config.allowUnsupportedSystem = true;

  users.users.root.initialPassword = "toor";

  networking.dhcpcd.wait = "background";

  users.users.bestie = {
    isNormalUser = true;
    description = "your bestie";
    extraGroups = [ "wheel" ];
    inherit (config.users.users.root) initialPassword;
  };

  services.sshd.enable = true;
  boot.loader.stand-freebsd.enable = true;

  fileSystems."/" = {
    device = "/dev/gpt/nixos";
    fsType = "ufs";
  };

  fileSystems."/boot" = {
    device = "/dev/msdosfs/ESP";
    fsType = "msdosfs";
  };

  virtualisation.vmVariant.virtualisation.diskImage = "./${config.system.name}.qcow2";
}
