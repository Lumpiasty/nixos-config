{
  self,
  nixpkgs,
  nixbsd,
  home-manager,
  nix-flatpak,
  plasma-manager,
  lanzaboote,
  claude-code,
  nix-sweep,
  peerix,
  acer-wmi-ext,
  ...
}:
hostConfig:

nixbsd.lib.nixbsdSystem {
  modules = [
    # Cross-compile FreeBSD from Linux, builds dispatched to remote builder
    {
      nixpkgs.buildPlatform = "x86_64-linux";
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.overlays = [
        (final: prev: {
          # No-op emulator for FreeBSD - builds happen on remote builder where binaries run natively
          freebsdEmulator = prev.runCommand "freebsd-emulator" { } ''
            mkdir -p $out/bin
            cat > $out/bin/freebsd-exec << 'SCRIPT'
            #!/bin/sh
            exec "$@"
            SCRIPT
            chmod +x $out/bin/freebsd-exec
          '';

          # Override mesonEmulatorHook to not require a real emulator for FreeBSD
          mesonEmulatorHook =
            let
              canExec = prev.stdenv.hostPlatform.canExecute prev.stdenv.targetPlatform;
              emulatorPath = "${final.freebsdEmulator}/bin/freebsd-exec";
            in
            if canExec then
              prev.mesonEmulatorHook
            else
              prev.makeSetupHook
                {
                  name = "mesonEmulatorHook";
                  substitutions = {
                    crossFile = prev.writeText "cross-file.conf" ''
                      [binaries]
                      exe_wrapper = '${prev.lib.escape [ "'" "\\" ] emulatorPath}'
                    '';
                  };
                }
                "${nixpkgs.outPath}/pkgs/build-support/setup-hooks/meson/emulator-hook.sh";
        })
      ];
    }
    hostConfig
  ];
}
