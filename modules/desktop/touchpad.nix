{ config, lib, pkgs, modulesPath, ... }:

# Touch pad configuration interface

let
  scrollMethods = {
    twoFingers = "twoFingers";
    touchPadEdges = "touchPadEdges";
  };
  rightClickMethods = {
    bottomRight = "bottomRight";
    twoFingers = "twoFingers";
  };
  accelerationProfiles = {
    none = "none";
    default = "default";
  };
in
{
  # Copy of https://github.com/nix-community/plasma-manager/blob/trunk/modules/input.nix#L69
  options.lumpiasty.touchPad = {
    enable = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to enable the touchpad.
      '';
    };
    name = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "PNP0C50:00 0911:5288 Touchpad";
      description = ''
        The name of the touchpad.

        This can be found by looking at the `Name` attribute in the section in
        the `/proc/bus/input/devices` path belonging to the touchpad.
      '';
    };
    vendorId = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "0911";
      description = ''
        The vendor ID of the touchpad.

        This can be found by looking at the `Vendor` attribute in the section in
        the `/proc/bus/input/devices` path belonging to the touchpad.
      '';
    };
    productId = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "5288";
      description = ''
        The product ID of the touchpad.

        This can be found by looking at the `Product` attribute in the section in
        the `/proc/bus/input/devices` path belonging to the touchpad.
      '';
    };
    disableWhileTyping = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to disable the touchpad while typing.
      '';
    };
    leftHanded = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = false;
      description = ''
        Whether to swap the left and right buttons.
      '';
    };
    middleButtonEmulation = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = false;
      description = ''
        Whether to enable middle mouse click emulation by pressing the left and right buttons at the same time.
        Activating this increases the click latency by 50ms.
      '';
    };
    pointerSpeed = lib.mkOption {
      type = with lib.types; nullOr (numbers.between (-1) 1);
      default = null;
      example = "0";
      description = ''
        How fast the pointer moves.
      '';
    };
    accelerationProfile = lib.mkOption {
      type = with lib.types; nullOr (enum (builtins.attrNames accelerationProfiles));
      default = null;
      example = "none";
      description = "Set the touchpad acceleration profile.";
      apply = profile: if (profile == null) then null else accelerationProfiles."${profile}";
    };
    naturalScroll = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to enable natural scrolling for the touchpad.
      '';
    };
    tapToClick = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to enable tap-to-click for the touchpad.
      '';
    };
    tapAndDrag = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to enable tap-and-drag for the touchpad.
      '';
    };
    tapDragLock = lib.mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Whether to enable the tap-and-drag lock for the touchpad.
      '';
    };
    scrollMethod = lib.mkOption {
      type = with lib.types; nullOr (enum (builtins.attrNames scrollMethods));
      default = null;
      example = "touchPadEdges";
      description = ''
        Configure how scrolling is performed on the touchpad.
      '';
      apply = method: if (method == null) then null else scrollMethods."${method}";
    };
    scrollSpeed = lib.mkOption {
      type = with lib.types; nullOr (numbers.between 0.1 20);
      default = null;
      example = 0.1;
      description = ''
        Configure the scrolling speed of the touchpad. Lower is slower.
        If unset, KDE Plasma will default to 0.3.
      '';
    };
    rightClickMethod = lib.mkOption {
      type = with lib.types; nullOr (enum (builtins.attrNames rightClickMethods));
      default = null;
      example = "twoFingers";
      description = ''
        Configure how right-clicking is performed on the touchpad.
      '';
      apply = method: if (method == null) then null else rightClickMethods."${method}";
    };
    twoFingerTap = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "rightClick"
          "middleClick"
        ]);
      default = null;
      example = "twoFingers";
      description = ''
        Configure what a two-finger tap maps to on the touchpad.
      '';
      apply = v: if (v == null) then null else (v == "middleClick");
    };
  };
}
