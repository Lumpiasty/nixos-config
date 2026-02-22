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
    environment.systemPackages =
      (lib.pipe pkgs.kdePackages.sources [
        builtins.attrNames
        (builtins.map (n: pkgs.kdePackages.${n}))
        (builtins.filter (pkg: !pkg.meta.broken))
        # Exclude neochat and itinerary due to known vulnerabilities
        (builtins.filter (pkg: pkg.pname != "neochat"))
        (builtins.filter (pkg: pkg.pname != "itinerary"))
        (builtins.filter (pkg: pkg.pname != "libquotient"))

        # Exclude angelfish due to build failure
        (builtins.filter (pkg: pkg.pname != "angelfish"))

        # Exclude step due to build failure
        (builtins.filter (pkg: pkg.pname != "step"))

        # Exclude plasma-vault due to build failure
        (builtins.filter (pkg: pkg.pname != "plasma-vault"))

        # Exclude kalzium due to build failure
        (builtins.filter (pkg: pkg.pname != "kalzium"))

        # Exclude audiocd-kio due to build failure
        (builtins.filter (pkg: pkg.pname != "audiocd-kio"))

        # Exclude plasma-mobile
        (builtins.filter (pkg: pkg.pname != "plasma-mobile"))
      ]) ++ [
        # Printing support in Plasma settings
        pkgs.system-config-printer
      ];

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
    services.avahi.enable = true;

  };

}