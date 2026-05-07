{
  self,
  nixpkgs,
  home-manager,
  nix-flatpak,
  plasma-manager,
  lanzaboote,
  claude-code,
  nix-sweep,
  peerix,
  acer-wmi-ext,
  ntfsplus,
  nix-skills,
  ...
}:
hardwareConfig: hostConfig:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit nix-flatpak;
    inherit plasma-manager;
    inherit acer-wmi-ext;
  };
  modules = [
    {
      nixpkgs.overlays = [
        claude-code.overlays.default
        acer-wmi-ext.overlays.default
        nix-skills.overlays.default
      ];
      nix.settings = {
        substituters = [ "https://claude-code.cachix.org" ];
        trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
      };
    }
    lanzaboote.nixosModules.lanzaboote
    hardwareConfig
    home-manager.nixosModules.home-manager
    nix-sweep.nixosModules.default
    peerix.nixosModules.peerix
    ntfsplus.nixosModules.default
    ../modules
    hostConfig
  ];
}
