self: super:
{
  opencode-claude-auth = super.callPackage ../pkgs/opencode-claude-auth {};
  linuxPackages = super.linuxPackages.extend (lpself: lpsuper: {
    acer-wmi-ext = lpsuper.callPackage ../pkgs/acer-wmi-ext {};
  });
}