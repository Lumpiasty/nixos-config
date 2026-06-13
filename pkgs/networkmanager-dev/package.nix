# NetworkManager 1.57.4-dev — development snapshot with ipv4.clat (CLAT/464XLAT) support.
# Required for IPv6-mostly / RFC 8925 + RFC 6877 on NixOS until 1.58 stable lands in nixpkgs.
# Remove this override once nixpkgs ships networkmanager >= 1.58.
{
  lib,
  stdenv,
  fetchurl,
  replaceVars,
  gettext,
  pkg-config,
  dbus,
  gitUpdater,
  libuuid,
  polkit,
  gnutls,
  ppp,
  dhcpcd,
  iptables,
  nftables,
  python3,
  vala,
  libgcrypt,
  dnsmasq,
  bluez5,
  readline,
  libselinux,
  audit,
  gobject-introspection,
  perl,
  modemmanager,
  openresolv,
  libndp,
  newt,
  ethtool,
  gnused,
  iputils,
  kmod,
  jansson,
  elfutils,
  gtk-doc,
  libxslt,
  docbook_xsl,
  docbook_xml_dtd_412,
  docbook_xml_dtd_42,
  docbook_xml_dtd_43,
  curl,
  meson,
  mesonEmulatorHook,
  ninja,
  bpftools,
  llvmPackages,
  libbpf,
  libnvme,
  libpsl,
  mobile-broadband-provider-info,
  runtimeShell,
  buildPackages,
  nixosTests,
  systemd,
  udev,
  udevCheckHook,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  withNbft ? false,
}:

let
  pythonForDocs = python3.pythonOnBuildForHost.withPackages (pkgs: with pkgs; [ pygobject3 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "networkmanager";
  version = "1.57.4-dev";

  src = fetchurl {
    # Use the stable release tarball (not the git archive) — GitLab git archives are not content-stable.
    url = "https://gitlab.freedesktop.org/api/v4/projects/411/packages/generic/NetworkManager/${finalAttrs.version}/NetworkManager-${finalAttrs.version}.tar.xz";
    hash = "sha256-ThYPO/0YsmFSc2Qol1ZAoQb1qdtjPRg+rvxpUzKe0sA=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "man"
    "doc"
  ];

  mesonFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (lib.mesonOption "systemdsystemunitdir" (
      if withSystemd then "${placeholder "out"}/etc/systemd/system" else "no"
    ))
    "-Dudev_dir=${placeholder "out"}/lib/udev"
    "-Ddbus_conf_dir=${placeholder "out"}/share/dbus-1/system.d"
    "-Dkernel_firmware_dir=/run/current-system/firmware"

    "-Dmodprobe=${kmod}/bin/modprobe"
    (lib.mesonOption "session_tracking" (if withSystemd then "systemd" else "no"))
    (lib.mesonBool "systemd_journal" withSystemd)
    "-Dlibaudit=yes-disabled-by-default"
    "-Dpolkit_agent_helper_1=/run/wrappers/bin/polkit-agent-helper-1"

    "-Diwd=true"
    "-Dpppd=${ppp}/bin/pppd"
    "-Diptables=${iptables}/bin/iptables"
    "-Dnft=${nftables}/bin/nft"
    "-Dmodem_manager=true"
    "-Dnmtui=true"
    "-Ddnsmasq=${dnsmasq}/bin/dnsmasq"
    "-Dqt=false"
    (lib.mesonBool "nbft" withNbft)

    "-Dresolvconf=${openresolv}/bin/resolvconf"
    "-Ddhcpcd=${dhcpcd}/bin/dhcpcd"

    "-Ddocs=${lib.boolToString (stdenv.buildPlatform == stdenv.hostPlatform)}"
    "-Dman=${lib.boolToString (stdenv.buildPlatform == stdenv.hostPlatform)}"
    "-Dtests=no"
    "-Dcrypto=gnutls"
    "-Dmobile_broadband_provider_info_database=${mobile-broadband-provider-info}/share/mobile-broadband-provider-info/serviceproviders.xml"
  ];

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit
        ethtool
        gnused
        ;
      inherit runtimeShell;
    })
    ./fix-install-paths.patch
    # CLAT prefix selection ignores RFC 6724 rule 3 (avoid deprecated addresses):
    # a deprecated prefix (preferred lifetime 0) can win the selection and break
    # CLAT with an unroutable source address. Report upstream, then drop this.
    ./clat-skip-deprecated-prefixes.patch
  ];

  buildInputs = [
    (if withSystemd then systemd else udev)
    libselinux
    audit
    libpsl
    libuuid
    polkit
    ppp
    libndp
    curl
    mobile-broadband-provider-info
    bluez5
    dnsmasq
    modemmanager
    readline
    newt
    jansson
    dbus
    libbpf
  ]
  ++ lib.optionals withNbft [
    libnvme
  ];

  propagatedBuildInputs = [
    gnutls
    libgcrypt
  ];

  # Disable hardening flags that break clang -target bpf (CLAT BPF compilation).
  # Same workaround as nixpkgs systemd package.
  hardeningDisable = [ "zerocallusedregs" "shadowstack" "pacret" ];

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    # BPF compiler for CLAT/464XLAT — must use buildPackages to avoid splicing issues
    bpftools
    buildPackages.llvmPackages.clang
    buildPackages.llvmPackages.libllvm
    vala
    gobject-introspection
    perl
    elfutils
    gtk-doc
    libxslt
    docbook_xsl
    docbook_xml_dtd_412
    docbook_xml_dtd_42
    docbook_xml_dtd_43
    pythonForDocs
    udevCheckHook
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  doCheck = false;

  postPatch = ''
    patchShebangs ./tools
    patchShebangs libnm/generate-setting-docs.py

    # TODO: submit upstream
    substituteInPlace meson.build \
      --replace "'vala', req" "'vala', native: false, req"
  ''
  + lib.optionalString withSystemd ''
    substituteInPlace data/NetworkManager.service.in \
      --replace-fail /usr/bin/busctl ${systemd}/bin/busctl
  '';

  preBuild = ''
    mkdir -p ${placeholder "out"}/lib
    ln -s $PWD/src/libnm-client-impl/libnm.so.0 ${placeholder "out"}/lib/libnm.so.0
  '';

  postFixup = lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
    cp -r ${buildPackages.networkmanager.devdoc} $devdoc
    cp -r ${buildPackages.networkmanager.man} $man
  '';

  doInstallCheck = true;

  passthru = {
    tests = {
      inherit (nixosTests.networking) networkmanager;
    };
  };

  meta = {
    homepage = "https://networkmanager.dev";
    description = "Network configuration and management tool (1.57.4-dev with CLAT/ipv6-mostly support)";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ obadz ];
    teams = [ lib.teams.freedesktop ];
    platforms = lib.platforms.linux;
    badPlatforms = [
      lib.systems.inspect.platformPatterns.isStatic
    ];
  };
})
