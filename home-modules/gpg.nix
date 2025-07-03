{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.gpg = lib.mkEnableOption "Enable GPG with SSH";

  config = lib.mkIf config.lumpiastyHome.gpg {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
      extraConfig = ''
        listen-backlog 256
        '';
    };

    programs.gpg.enable = true;

    programs.bash.enable = lib.mkDefault true;
  };
}