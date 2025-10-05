{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.enableTailscale = lib.mkEnableOption "Enable Tailscale VPN";

  config = lib.mkIf config.lumpiasty.enableTailscale {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=user" ];
    };
  };
}