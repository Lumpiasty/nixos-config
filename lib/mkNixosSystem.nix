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
  };
  modules = [
    {
      nixpkgs.overlays = [
        claude-code.overlays.default
        acer-wmi-ext.overlays.default
        nix-skills.overlays.default
        nix-cachyos-kernel.overlays.pinned
      ] ++ (import ../overlays/pkgs.nix { inherit bun2nix; });
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
