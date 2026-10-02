{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = [ pkgs.headsetcontrol pkgs.headset-battery-indicator ];
  services.udev.packages = [ pkgs.headsetcontrol ];  # for udev rules
}
