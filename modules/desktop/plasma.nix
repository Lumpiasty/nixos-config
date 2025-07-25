{ config, lib, pkgs, modulesPath, ... }:

{
  options.lumpiasty.enablePlasma = lib.mkEnableOption "Enable Plasma6 desktop";

  config = lib.mkIf config.lumpiasty.enablePlasma {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "pl";
      variant = "";
    };

    # Configure console keymap
    console.keyMap = "pl2";

    # Enable external monitor brightness control
    hardware.i2c.enable = true;
    
    # Network
    networking.useDHCP = lib.mkDefault false;
    networking.networkmanager.enable = lib.mkDefault true;
    networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Use wayland in electron apps
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };

}