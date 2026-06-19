{
  self,
  nixpkgs,
  nixpkgs-2605,
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
  nixpkgs-linuxeol,
  bun2nix,
  nix-cachyos-kernel,
  ...
}:
hardwareConfig: hostConfig:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit nix-flatpak;
    inherit plasma-manager;
    inherit acer-wmi-ext;
    inherit nixpkgs-linuxeol;
    inherit ntfsplus;
  };
  modules = [
    {
      nixpkgs.overlays = [
        (final: prev: {
          librewolf = nixpkgs-2605.legacyPackages.${prev.system}.librewolf;
        })
        claude-code.overlays.default
        acer-wmi-ext.overlays.default
        nix-skills.overlays.default
        nix-cachyos-kernel.overlays.pinned
      ] ++ (import ../overlays/pkgs.nix { inherit bun2nix; });
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
    ../modules
    hostConfig
  ];
}
