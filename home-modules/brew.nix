{ config, lib, pkgs, ... }:

{
  options.lumpiastyHome.brew = lib.mkEnableOption "Homebrew integration via home-manager-brew";

  config = lib.mkMerge [
    (lib.mkIf config.lumpiastyHome.brew {
      homebrew = {
        enable = true;
        brewInstall = true;
        update = true;
        upgrade = true;
        cleanup = true;
        casks = [
          "steam"
        ];
      };
    })
    (lib.mkIf (!config.lumpiastyHome.brew) {
      homebrew.enable = lib.mkForce false;
    })
  ];
}
