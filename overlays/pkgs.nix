self: super:
{
  opencode-claude-auth = super.callPackage ../pkgs/opencode-claude-auth {};
  # Build failure 08.05.2026
  # https://github.com/NixOS/nixpkgs/issues/513245#issuecomment-4320293674
  openldap = super.openldap.overrideAttrs {
    doCheck = !super.stdenv.hostPlatform.isi686;
  };
}