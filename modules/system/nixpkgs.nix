{ config, lib, pkgs, modulesPath, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    # Ventoy has some blobs making it insecure
    "ventoy-qt5-1.1.12"
  ];
}