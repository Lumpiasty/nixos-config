{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.sshd = lib.mkEnableOption "Enable intel CPU";

  config = lib.mkIf config.lumpiasty.sshd {
    services.openssh = {
      enable = true;
      settings = {
          PasswordAuthentication = false;
          AllowUsers = [ "user" ];
      };
    };
  };
}