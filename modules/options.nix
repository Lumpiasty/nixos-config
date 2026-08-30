{ config, lib, ... }:

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
  options.lumpiasty = {
    pc = lib.mkEnableOption "Enable options specific to personal computers";
    laptop = lib.mkEnableOption "Enable options specific to laptops";
    intelCpu = lib.mkEnableOption "Enable intel CPU";
    amdCpu = lib.mkEnableOption "Enable amd CPU";
    noMitigations = lib.mkEnableOption "Disable mitigations";
    acerUndervolt = lib.mkEnableOption "ryzenadj + ryzen_smu tooling for Acer 8845HS";
    enablePlasma = lib.mkEnableOption "Enable Plasma6 desktop";
    enableGnome = lib.mkEnableOption "Enable Gnome desktop";
    enablePulseaudio = lib.mkEnableOption "Enable Pulseaudio/Pipewire";
    enableTailscale = lib.mkEnableOption "Enable Tailscale VPN";
    sshd = lib.mkEnableOption "Enable OpenSSH server";
    gaming = lib.mkEnableOption "Enable options specific to gaming computers";
    scx = lib.mkEnableOption "Enable sched-ext";
    ipv6Mostly = lib.mkEnableOption "Enable IPv6-mostly (RFC 8925 + CLAT/464XLAT) support in NetworkManager";

    users = {
      user = lib.mkEnableOption "Create user \"user\"";
      drugi = lib.mkEnableOption "Create user \"drugi\"";
    };

    touchPad = {
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

    audioRt = {
      enable = lib.mkEnableOption "Audio RT scheduling and CPU isolation";

      audioCpus = lib.mkOption {
        type = lib.types.str;
        default = "12-15";
        description = "CPU list reserved for audio services (systemd cpuset syntax).";
      };

      nonAudioCpus = lib.mkOption {
        type = lib.types.str;
        default = "0-11";
        description = "CPU list for everything else.";
      };

      cpuPartitioning = lib.mkOption {
        type = lib.types.bool;
        default = config.lumpiasty.audioRt.enable;
        description = ''
          Cgroup-based CPU partitioning via dedicated audio.slice and
          restricted app/session/background slices.
        '';
      };

      rtLimits = lib.mkOption {
        type = lib.types.bool;
        default = config.lumpiasty.audioRt.enable;
        description = ''
          Raise rlimits (RTPRIO=95, MEMLOCK=infinity) for the audio group
          so PipeWire's module-rt can set SCHED_FIFO 88 directly instead
          of going through RTKit's priority-10 ceiling.
        '';
      };

      performanceGovernor = lib.mkOption {
        type = lib.types.bool;
        default = config.lumpiasty.audioRt.enable;
        description = ''
          Keep cpufreq governor `performance` on the audio cores so they
          stay boosted regardless of measured utilization.
        '';
      };

      ananicy = lib.mkOption {
        type = lib.types.bool;
        default = config.lumpiasty.audioRt.enable;
        description = ''
          Run ananicy-cpp with a rule that pins easyeffects to nice -12 so
          its non-RT DSP threads get scheduler preference under load.
        '';
      };

      optimisedBinaries = lib.mkOption {
        type = lib.types.bool;
        default = config.lumpiasty.audioRt.enable;
        description = ''
          Rebuild easyeffects and its DSP dependencies with -march=znver4 -O3
          (and LTO for cmake builds, target-cpu for rust builds).
        '';
      };
    };
  };
}
