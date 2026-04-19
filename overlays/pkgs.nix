self: super:
{
  ddccontrol = super.callPackage ../pkgs/ddccontrol {};
  opencode-claude-auth = super.callPackage ../pkgs/opencode-claude-auth {};
  # Pin some kde packages to 6.3.1, 6.3.2 breaks thunderbolt
  # kdePackages = super.kdePackages.overrideScope(kdeFinal: kdePrev: {
  #   kwin = kdePrev.kwin.overrideAttrs (prevAttrs: {
  #     src = super.fetchurl {
  #       url = "mirror://kde/stable/plasma/6.3.1/kwin-6.3.1.tar.xz";
  #       hash = "sha256-mlC6DqpiCXg73vu2aOV9DL36cc6Ov70X/kRtttdz8kI=";
  #     };
  #     version = "6.3.1";
  #   });
  # });
  linuxPackages = super.linuxPackages.extend (lpself: lpsuper: {
    acer-wmi-ext = lpsuper.callPackage ../pkgs/acer-wmi-ext {};
    acer-wmi-battery = lpsuper.callPackage ../pkgs/acer-wmi-battery {};
  });
}