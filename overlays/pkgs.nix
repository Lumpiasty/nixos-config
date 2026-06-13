{ bun2nix }:

[
  bun2nix.overlays.default
  (final: prev: {
    oh-my-pi = final.callPackage ../pkgs/oh-my-pi { inherit (final) bun2nix; };
    opencode-claude-auth = prev.callPackage ../pkgs/opencode-claude-auth { };
    # Build failure 08.05.2026
    # https://github.com/NixOS/nixpkgs/issues/513245#issuecomment-4320293674
    openldap = prev.openldap.overrideAttrs {
      doCheck = !prev.stdenv.hostPlatform.isi686;
    };
    # NetworkManager 1.57.4-dev: adds ipv4.clat (CLAT/464XLAT) needed for IPv6-mostly.
    # Used via networking.networkmanager.package — does not replace pkgs.networkmanager globally.
    # Remove once nixpkgs ships networkmanager >= 1.58 stable.
    networkmanager-clat = assert final.lib.assertMsg
      (final.lib.versionOlder prev.networkmanager.version "1.58")
      "nixpkgs now ships NetworkManager ${prev.networkmanager.version} >= 1.58 — remove the override in overlays/pkgs.nix and pkgs/networkmanager-dev/";
      prev.callPackage ../pkgs/networkmanager-dev/package.nix { };
  })
]
