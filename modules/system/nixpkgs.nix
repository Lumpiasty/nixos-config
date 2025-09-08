{ config, lib, pkgs, modulesPath, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19" # Required for teamspeak_client
  ];

  # Overlay different packages on top of nixpkgs
  nixpkgs.overlays = [
    (import ../../overlays/pkgs.nix)
  ];
}