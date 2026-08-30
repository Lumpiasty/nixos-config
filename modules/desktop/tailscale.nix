{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkIf config.lumpiasty.enableTailscale {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=user" ];
      useRoutingFeatures = "client";
    };
    environment.systemPackages = [ pkgs.ktailctl ];
  };
}