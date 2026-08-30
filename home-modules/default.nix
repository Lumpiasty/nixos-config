{ flake, pkgs, lib, osConfig ? null, ... }:

{
  imports = [
    ./gpg.nix
    ./pc.nix
    ./dev.nix
    ./gaming.nix
    ./fhsBash.nix
  ] ++ lib.optionals (osConfig.lumpiasty.enablePlasma) [
    ./plasma.nix
  ];
}