{ lib, nix-flatpak, plasma-manager }:
condition: home:

lib.mkIf condition (
  { ... }: {
    imports = [
      nix-flatpak.homeManagerModules.nix-flatpak
      plasma-manager.homeModules.plasma-manager
      ../home-modules
      home
    ];
  }
)
