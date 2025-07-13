{ self, nixpkgs, home-manager, nix-flatpak, plasma-manager, ... }:
hardwareConfig: hostConfig:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit nix-flatpak;
    inherit plasma-manager;
  };
  modules = [
    hardwareConfig
    home-manager.nixosModules.home-manager
    ../modules
    hostConfig
  ];
}
