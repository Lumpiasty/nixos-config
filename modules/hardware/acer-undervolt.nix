{ config, lib, pkgs, ... }:

# Manual undervolting / power tuning for Ryzen 7 8845HS (Hawk Point, znver4).
#
# Provides:
#   - ryzen_smu kernel module (loaded at boot)
#   - ryzenadj userspace tool for poking the SMU
#
# nixpkgs already ships:
#   - linuxPackages.ryzen-smu from the amkillam fork (Phoenix/Hawk Point aware)
#   - ryzenadj v0.17.0 which has Hawk Point support and talks to ryzen_smu
#     via the kernel module backend (preferred over /dev/mem).
# So no custom forks/overrides are needed any more.
#
# This module deliberately does NOT apply any tuning automatically.
# Run `ryzenadj` manually as root to experiment, then come back with
# results and we'll decide whether to wire in a systemd service to
# persist values across boot / resume.

{
  options.lumpiasty.acerUndervolt = lib.mkEnableOption "ryzenadj + ryzen_smu tooling for Acer 8845HS";

  config = lib.mkIf config.lumpiasty.acerUndervolt {
    boot.kernelModules = [ "ryzen_smu" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.ryzen-smu ];

    environment.systemPackages = [ pkgs.ryzenadj ];

    # CoreCtrl for GPU/iGPU tuning + amdgpu overdrive for clock/voltage
    # control on the 780M iGPU. Orthogonal to CPU undervolt but lives
    # naturally in the same module.
    programs.corectrl.enable = true;
    hardware.amdgpu.overdrive.enable = true;
  };
}
