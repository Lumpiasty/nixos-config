{ config, lib, pkgs, ... }:

# Workarounds for audio xruns under CPU load.
#
# Each optimization is independently toggleable so behavior can be bisected.
# `lumpiasty.audioRt.enable` is the master switch; individual sub-flags default
# to `true` when the master is on and can be flipped per-host to test impact.

let
  cfg = config.lumpiasty.audioRt;

  marchFlags = " -march=znver4 -O3";

  # ---------------------------------------------------------------------------
  # Per-build-system helpers (see commit history for rationale on LTO choices).
  # ---------------------------------------------------------------------------
  withMarch = pkg: pkg.overrideAttrs (old: {
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE =
        ((old.env or {}).NIX_CFLAGS_COMPILE or old.NIX_CFLAGS_COMPILE or "")
        + marchFlags;
    };
  });

  cmakePkg = pkg: pkg.overrideAttrs (old: {
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE =
        ((old.env or {}).NIX_CFLAGS_COMPILE or old.NIX_CFLAGS_COMPILE or "")
        + marchFlags;
    };
    cmakeFlags = (old.cmakeFlags or []) ++ [ "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON" ];
    preConfigure = (old.preConfigure or "") + "\nexport AR=gcc-ar\n";
  });

  rustPkg = pkg: pkg.overrideAttrs (old: {
    RUSTFLAGS = (old.RUSTFLAGS or "") + " -C target-cpu=znver4";
  });

in

{
  options.lumpiasty.audioRt = {
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

    # ------ Individual optimization toggles ------

    cpuPartitioning = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Cgroup-based CPU partitioning via dedicated audio.slice and
        restricted app/session/background slices.
      '';
    };

    rtLimits = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Raise rlimits (RTPRIO=95, MEMLOCK=infinity) for the audio group
        so PipeWire's module-rt can set SCHED_FIFO 88 directly instead
        of going through RTKit's priority-10 ceiling.
      '';
    };

    performanceGovernor = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Keep cpufreq governor `performance` on the audio cores so they
        stay boosted regardless of measured utilization.
      '';
    };

    ananicy = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Run ananicy-cpp with a rule that pins easyeffects to nice -12 so
        its non-RT DSP threads get scheduler preference under load.
      '';
    };

    optimisedBinaries = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = ''
        Rebuild easyeffects and its DSP dependencies with -march=znver4 -O3
        (and LTO for cmake builds, target-cpu for rust builds).
      '';
    };
  };

  config = lib.mkMerge [

    # --- Optimised binary builds ---------------------------------------------
    (lib.mkIf (cfg.enable && cfg.optimisedBinaries) {
      nixpkgs.overlays = [
        (final: prev: {
          easyeffects = cmakePkg (prev.easyeffects.override {
            fftw          = withMarch prev.fftw;
            fftwFloat     = withMarch prev.fftwFloat;
            speexdsp      = withMarch prev.speexdsp;
            rubberband    = withMarch prev.rubberband;
            soundtouch    = withMarch prev.soundtouch;
            zita-convolver          = withMarch prev.zita-convolver;
            webrtc-audio-processing = withMarch prev.webrtc-audio-processing;
            rnnoise       = withMarch prev.rnnoise;
            libebur128    = cmakePkg prev.libebur128;
            libbs2b       = withMarch prev.libbs2b;
            lilv          = withMarch prev.lilv;
            onetbb        = cmakePkg prev.onetbb;
            calf          = cmakePkg prev.calf;
            lsp-plugins   = withMarch prev.lsp-plugins;
            zam-plugins   = withMarch prev.zam-plugins;
            mda_lv2       = withMarch prev.mda_lv2;
            deepfilternet = rustPkg  prev.deepfilternet;
          });
        })
      ];
    })

    # --- RT scheduling rlimits ----------------------------------------------
    (lib.mkIf (cfg.enable && cfg.rtLimits) {
      security.pam.loginLimits = [
        { domain = "@audio"; type = "-"; item = "rtprio";  value = "95"; }
        { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
        { domain = "@audio"; type = "-"; item = "nice";    value = "-20"; }
      ];
      systemd.user.extraConfig = ''
        DefaultLimitRTPRIO=95
        DefaultLimitMEMLOCK=infinity
      '';
    })

    # --- CPU partitioning (cgroup-based) ------------------------------------
    #
    # Cgroup hierarchy under user@.service:
    #   ├── app.slice         AllowedCPUs=<nonAudioCpus>  (Steam-launched apps)
    #   ├── session.slice     AllowedCPUs=<nonAudioCpus>  (kwin, plasmashell, kded)
    #   ├── background.slice  AllowedCPUs=<nonAudioCpus>  (akonadi, polkit)
    #   └── audio.slice       AllowedCPUs=<audioCpus>     (pipewire, easyeffects)
    #
    # Reasoning:
    #   - No isolcpus= : breaks scheduler load balancing on the rest of the system.
    #   - No nohz_full= : amd-pstate can't sample utilization in tickless mode
    #     so cores get clamped at minimum frequency.
    #   - No rcu_nocbs= : microsecond-scale jitter is irrelevant at 21ms quantum.
    (lib.mkIf (cfg.enable && cfg.cpuPartitioning) {
      systemd.user.extraConfig = ''
        CPUAffinity=${cfg.nonAudioCpus}
      '';
      systemd.settings.Manager.CPUAffinity = cfg.nonAudioCpus;

      # Delegate the cpuset controller to user managers so user-level slices
      # can use AllowedCPUs=.
      systemd.services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";

      systemd.user.slices = {
        app.sliceConfig.AllowedCPUs = cfg.nonAudioCpus;
        session.sliceConfig.AllowedCPUs = cfg.nonAudioCpus;
        background.sliceConfig.AllowedCPUs = cfg.nonAudioCpus;
        audio = {
          description = "Audio services pinned to reserved CPU cores";
          sliceConfig.AllowedCPUs = cfg.audioCpus;
        };
      };

      # easyeffects.service Slice= is set in home-modules/pc.nix.
      systemd.user.services.pipewire.serviceConfig.Slice = "audio.slice";
      systemd.user.services.pipewire-pulse.serviceConfig.Slice = "audio.slice";
      systemd.user.services.wireplumber.serviceConfig.Slice = "audio.slice";
    })

    # --- Performance governor on audio cores --------------------------------
    (lib.mkIf (cfg.enable && cfg.performanceGovernor) {
      systemd.services.audio-cores-performance = {
        description = "Keep performance governor on audio cores";
        wantedBy = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "5s";
          # Expand systemd CPU list ("12-15" / "12,13,14,15") into a flat list.
          ExecStart = pkgs.writeShellScript "audio-cores-performance" ''
            cpus=$(echo "${cfg.audioCpus}" | ${pkgs.coreutils}/bin/tr ',' ' ' | \
              ${pkgs.gawk}/bin/awk '{
                for (i=1; i<=NF; i++) {
                  if (match($i, /^([0-9]+)-([0-9]+)$/, m))
                    for (j=m[1]; j<=m[2]; j++) print j
                  else print $i
                }
              }')
            while true; do
              for cpu in $cpus; do
                cur=$(cat /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor)
                if [ "$cur" != "performance" ]; then
                  echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
                fi
              done
              sleep 2
            done
          '';
        };
      };
    })

    # --- Ananicy rule for easyeffects ---------------------------------------
    (lib.mkIf (cfg.enable && cfg.ananicy) {
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        extraRules = [
          { name = "easyeffects"; type = "Audio"; nice = -12; }
        ];
      };
    })

  ];
}
