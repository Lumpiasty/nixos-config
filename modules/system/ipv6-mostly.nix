{ config, lib, pkgs, ... }:

# IPv6-mostly support via NetworkManager (RFC 8925 + RFC 6877 / 464XLAT).
# Requires NetworkManager >= 1.58 (pkgs.networkmanager-clat in practice).
# Sets ipv4.clat=auto and ipv4.dhcp-ipv6-only-preferred=auto as connection
# defaults, mirroring the Fedora 45 change:
# https://fedoraproject.org/wiki/Changes/IPv6-Mostly_Support_In_NetworkManager
{
  options.lumpiasty.ipv6Mostly = lib.mkEnableOption "Enable IPv6-mostly (RFC 8925 + CLAT/464XLAT) support in NetworkManager";

  config = lib.mkIf config.lumpiasty.ipv6Mostly {
    # Use the patched NM build with CLAT support, without replacing pkgs.networkmanager
    # globally (which would cascade rebuilds across the entire system closure).
    networking.networkmanager.package = pkgs.networkmanager-clat;

    # Drop a conf.d snippet that sets connection-level defaults.
    # NM reads /etc/NetworkManager/conf.d/*.conf in addition to NetworkManager.conf.
    environment.etc."NetworkManager/conf.d/99-ipv6-mostly.conf".text = ''
      # IPv6-mostly: automatically enable CLAT (464XLAT) and DHCPv4 option 108
      # when the network advertises PREF64 and/or option 108 (RFC 8925).
      # On networks without these, behaviour is unchanged (native IPv4 proceeds).
      [connection-defaults]
      ipv4.clat=auto
      ipv4.dhcp-ipv6-only-preferred=auto
    '';
  };
}
