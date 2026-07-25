{ bun2nix }:

[
  bun2nix.overlays.default
  (final: prev: {
    opencode-claude-auth = prev.callPackage ../pkgs/opencode-claude-auth { };
    opencode-antigravity-auth = final.callPackage ../pkgs/opencode-antigravity-auth { inherit (final) bun2nix; };
    # NetworkManager 1.57.4-dev: adds ipv4.clat (CLAT/464XLAT) needed for IPv6-mostly.
    # Used via networking.networkmanager.package — does not replace pkgs.networkmanager globally.
    # Remove once nixpkgs ships networkmanager >= 1.58 stable.
    networkmanager-clat = assert final.lib.assertMsg
      (final.lib.versionOlder prev.networkmanager.version "1.58")
      "nixpkgs now ships NetworkManager ${prev.networkmanager.version} >= 1.58 — remove the override in overlays/pkgs.nix and pkgs/networkmanager-dev/";
      prev.callPackage ../pkgs/networkmanager-dev/package.nix { };
  })
]
