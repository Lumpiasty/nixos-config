{ config, lib, pkgs, modulesPath, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlay different packages on top of nixpkgs
  nixpkgs.overlays = [
    (import ../../overlays/pkgs.nix)
  ];

  # Ventoy has some blobs making it insecure
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-qt5-1.1.10"
  ];
}