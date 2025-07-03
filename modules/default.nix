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

    desktop/plasma.nix
    desktop/pulseaudio.nix
  ];
}