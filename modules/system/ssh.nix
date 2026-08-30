{ config, lib, pkgs, modulesPath, ... }:

{
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