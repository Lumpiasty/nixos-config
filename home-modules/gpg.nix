{ config, lib, pkgs, osConfig, ... }:

{
  options.lumpiastyHome.gpg = lib.mkEnableOption "Enable GPG with SSH";

  config = lib.mkIf config.lumpiastyHome.gpg {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-qt;
      extraConfig = ''
        listen-backlog 256
        '';
    };

    programs.gpg.enable = true;

    programs.git.signing = {
      format = "openpgp";
      key = "EA287B39E5F69945";
      signByDefault = true;
    };

    programs.bash.enable = lib.mkDefault true;
  };
}