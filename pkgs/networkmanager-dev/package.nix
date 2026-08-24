# NetworkManager 1.57.4-dev — development snapshot with ipv4.clat (CLAT/464XLAT) support.
# Required for IPv6-mostly / RFC 8925 + RFC 6877 on NixOS until 1.58 stable lands in nixpkgs.
# Remove this override once nixpkgs ships networkmanager >= 1.58.
{
  networkmanager
}:

networkmanager.overrideAttrs (old: {
  patches = old.patches ++ [
    # CLAT prefix selection ignores RFC 6724 rule 3 (avoid deprecated addresses):
    # a deprecated prefix (preferred lifetime 0) can win the selection and break
    # CLAT with an unroutable source address. Report upstream, then drop this.
    ./clat-skip-deprecated-prefixes.patch
  ];
})
