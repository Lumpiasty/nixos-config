{ config, pkgs, lib, ntfsplus, ... }:

# Builds and loads the ntfsplus kernel driver (github:namjaejeon/linux-ntfs),
# a maintained out-of-tree NTFS driver for Linux 6.1+.
#
# The upstream driver is used as-is, with two local patches applied on top
# (see ntfsplus-patches/). This avoids maintaining a fork that would need
# rebasing on every upstream update — patches are plain files that apply
# cleanly regardless of upstream churn.
#
# The ntfsplus flake's nixosModule is NOT used directly. It builds the kernel
# module as a `let` binding inside the module closure — not exposed as a
# package in its flake outputs — so there is nothing in pkgs to override.
# Replicating the module here is the only way to substitute a patched source.
#
# The ntfsplus flake (github:cmspam/ntfsplus-flake) is reused only for:
#   - its linux-ntfs source input  (ntfsplus.inputs.linux-ntfs)
#   - its bundled Makefile         (${ntfsplus}/Makefile)
#     The flake ships its own Makefile because the upstream repo's Makefile
#     has an ifneq KERNELRELEASE guard that breaks the out-of-tree nix build.
#
# The derivation is built inside this module (not via an overlay) so that
# config.boot.kernelPackages.kernel resolves to whatever kernel the host
# declares, with no extra indirection or per-host maintenance.
#
# ntfsplus is passed in via specialArgs in lib/mkNixosSystem.nix.

let
  cfg = config.services.ntfsplus;

  patchedSrc = pkgs.applyPatches {
    name = "linux-ntfs-patched";
    src = ntfsplus.inputs.linux-ntfs;
    patches = [
      # fsparam_flag → fsparam_bool so windows_names=0/1 is accepted as a
      # mount option rather than being treated as a bare flag.
      ./ntfsplus-patches/0001-fix-windows_names-option.patch
      # Gate the bad-character check behind NVolCheckWindowsNames so that
      # the check only runs when windows_names is actually enabled.
      ./ntfsplus-patches/0002-gate-bad-character-check-by-windows_names.patch
    ];
  };

  ntfsplus-mod = pkgs.stdenv.mkDerivation {
    pname = "ntfsplus-module";
    version = ntfsplus.inputs.linux-ntfs.shortRev or ntfsplus.inputs.linux-ntfs.rev;
    src = patchedSrc;
    nativeBuildInputs = config.boot.kernelPackages.kernel.moduleBuildDependencies;
    preBuild = "cp ${ntfsplus}/Makefile Makefile";
    makeFlags = [
      "KDIR=${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build"
      "KVERSION=${config.boot.kernelPackages.kernel.modDirVersion}"
      "CONFIG_NTFS_FS_POSIX_ACL=y"
    ];
    installPhase = ''
      mkdir -p $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/extra
      cp ntfs.ko $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/extra/
    '';
  };
in
{
  options.services.ntfsplus = {
    enable = lib.mkEnableOption "ntfsplus kernel driver and utilities";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ ntfsplus-mod ];
    boot.kernelModules = [ "ntfs" ];
    boot.extraModprobeConfig = ''
      alias fs-ntfs ntfs
      alias ntfsplus ntfs
    '';
    services.udev.extraRules = ''
      SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs"
    '';
    environment.systemPackages = [ pkgs.ntfsprogs-plus ];
  };
}
