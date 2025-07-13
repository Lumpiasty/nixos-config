{ ... }:

{
  imports = [
    hardware/intel-cpu.nix
    hardware/no-mitigations.nix

    system/roles.nix
    system/nixpkgs.nix
    system/location.nix
    system/shell.nix
    system/users.nix
    system/ssh.nix
    system/gaming.nix

    desktop/plasma.nix
    desktop/touchpad.nix
    desktop/pulseaudio.nix
  ];
}