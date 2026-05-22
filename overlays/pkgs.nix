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
  })
]
