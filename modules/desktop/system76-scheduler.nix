{ config, lib, pkgs, modulesPath, ... }:

{

  # Enable system76-scheduler
  # Config basically rewrite of stock, a bit tuned
  services.system76-scheduler = {
    enable = true;
    useStockConfig = false;
    settings = {
      processScheduler = {
        pipewireBoost = {
          enable = true;
          profile = {
            nice = -6;
            ioClass = "best-effort";
            ioPrio = 0;
          };
        };
        foregroundBoost = {
          enable = true;
          foreground = {
            nice = 0;
            ioClass = "best-effort";
            ioPrio = 0;
          };
          background = {
            nice = 6;
            ioClass = "idle";
          };
        };
      };
    };
    assignments = {
      sound-server = {
        nice = -15;
        ioClass = "realtime";
        ioPrio = 0;
        matchers = [
          # original config matches on /usr/bin/..., but this is NixOS
          "pipewire"
          "pipewire-pulse"
          "jackd"
        ];
      };
      recording = {
        nice = -9;
        ioClass = "best-effort";
        ioPrio = 0;
        matchers = [
          "amsynth"
          "jamesdsp"
          "jitsi"
          "mumble"
          "obs"
          "teams"
          "wireplumber"
          "zoom"
          "bitwig-studio"
          "include name=\"Bitwig*\""
        ];
      };
      games = {
        nice = -5;
        ioClass = "best-effort";
        ioPrio = 0;
        matchers = [
          "lutris"
          "steam"
          "heroic"
          "itch"
          "vrcompositor"
          "vrdashboard"
          "vrmonitor"
          "vrserver"
          "include descends=\"steam\""
          "include descends=\"lutris\""
          "include descends=\"heroic\""
          "include descends=\"itch\""
        ];
      };
      desktop-environment = {
        nice = -3;
        ioClass = "best-effort";
        ioPrio = 0;
        matchers = [
          "cosmic-comp"
          "gnome-shell"
          "i3wm"
          "kwin"
          "kwin_wayland"
          "Xwayland"
          "sway"
          "Hyprland"
          "gamescope"
          "Xorg"
        ];
      };
      session-services = {
        nice = 9;
        ioClass = "idle";
        matchers = [
          "include parent=\"gnome-session-binary\""
          "include parent=\"gvfsd\""
          "include cgroup=\"/user.slice/*.service\" parent=\"systemd\""
          "include cgroup=\"/user.slice/*/session.slice/*\" parent=\"systemd\""
          "exclude cgroup=\"/user.slice/*/app.slice/*\""
          "exclude cgroup=\"/user.slice/*/session.slice/*\""
          "exclude cgroup=\"/user.slice/*app-dbus*\""
        ];
      };
      system-services = {
        nice = 12;
        ioClass = "idle";
        matchers = [
          "include cgroup=\"/system.slice/*\""
        ];
      };
      package-manager = {
        nice = 15;
        class = "batch";
        ioClass = "idle";
        matchers = [
          "include name=\"apt-*\""
          "include name=\"dpkg-*\""
          "apt"
          "dpkg"
          "flatpak"
          "fwupd"
          "packagekitd"
          "update-initramfs"
          "nix"
        ];
      };
      batch = {
        nice = 19;
        class = "idle";
        ioClass = "idle";
        matchers = [
          "include name=\"sbuild-*\""
          "\"7z\""
          "\"7za\""
          "\"7zr\""
          "ar"
          "boinc"
          "c++"
          "cargo"
          "clang"
          "cmake"
          "cpp"
          "FAHClient"
          "FAHCoreWrapper"
          "fossilize-replay"
          "g++"
          "gcc"
          "gradle"
          "javac"
          "ld"
          "lld"
          "make"
          "mold"
          "mvn"
          "ninja"
          "rust-analyzer"
          "rustc"
          "sbuild"
          "tar"
          "tracker-miner-fs-3"
          "unrar"
          "zip"
        ];
      };
    };
    exceptions = [
      "include descends=\"chrt\""
      "include descends=\"gamemoderun\""
      "include descends=\"ionice\""
      "include descends=\"nice\""
      "include descends=\"taskset\""
      "include descends=\"schedtool\""
      "chrt"
      "dbus"
      "dbus-broker"
      "gamemoderun"
      "ionice"
      "nice"
      "rtkit-daemon"
      "systemd"
      "taskset"
      "schedtool"
          "/etc/profiles/per-user/user/bin/easyeffects*"
    ];
  };
  # Add https://github.com/maxiberta/kwin-system76-scheduler-integration kwin script
}