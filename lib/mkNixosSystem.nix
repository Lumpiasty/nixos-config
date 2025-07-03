{ self, nixpkgs, home-manager, nix-flatpak, ... }:
hardwareConfig: hostConfig:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    nix-flatpak = nix-flatpak;
  };
  modules = [
    hardwareConfig
    home-manager.nixosModules.home-manager
    ../modules
    hostConfig
  ];
}
