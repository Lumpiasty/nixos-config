{ flake, pkgs, lib, osConfig ? null, ... }:

{
  options.lumpiastyHome.macos = lib.mkEnableOption "Macos specific things";

  imports = [
    ./gpg.nix
    ./pc.nix
    ./dev.nix
    ./gaming.nix
    ./fhsBash.nix
    ./linux.nix
  ] ++ lib.optionals (osConfig ? system.defaults) [
    # Can't use config.lumpiastyHome.macos here — imports are evaluated before config,
    # causing infinite recursion. osConfig ? system.defaults detects nix-darwin.
    ./macos.nix
  ] ++ lib.optionals (osConfig.lumpiasty.enablePlasma) [
    ./plasma.nix
  ];
}
