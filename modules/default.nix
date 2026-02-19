{ ... }:

{
  imports = [
    hardware/intel-cpu.nix
    hardware/amd-cpu.nix
    hardware/no-mitigations.nix
    hardware/acer-undervolt.nix

    system/roles.nix
    system/nixpkgs.nix
    system/location.nix
    system/shell.nix
    system/users.nix
    system/ssh.nix
    system/gaming.nix
    system/nix.nix
    system/zfs.nix

    desktop/plasma.nix
    desktop/touchpad.nix
    desktop/pulseaudio.nix
    desktop/tailscale.nix
  ];
}