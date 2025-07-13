{ flake, pkgs, lib, ... }:

{
  imports = [
    ./gpg.nix
    ./pc.nix
    ./dev.nix
    ./gaming.nix
  ];
}