{ lib, nix-flatpak }:
condition: home:

lib.mkIf condition (
  { ... }: {
    imports = [
      nix-flatpak.homeManagerModules.nix-flatpak
      ../home-modules
      home
    ];
  }
)
