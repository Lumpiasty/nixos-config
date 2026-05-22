{ config, lib, pkgs, modulesPath, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Ventoy has some blobs making it insecure
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-qt5-1.1.12"
  ];
}