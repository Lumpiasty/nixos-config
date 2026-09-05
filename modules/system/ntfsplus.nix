{ config, lib, pkgs, ... }:


{
  boot.extraModulePackages = [
    ((pkgs.callPackage ../../pkgs/ntfs/package.nix { kernel = config.boot.kernelPackages.kernel; }).overrideAttrs {
      patches = [
        ./ntfsplus-patches/0001-fix-windows_names-option.patch
        ./ntfsplus-patches/0002-gate-bad-character-check-by-windows_names.patch
        ];
    })
  ];
}
