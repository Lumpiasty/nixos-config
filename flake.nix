{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };
  
  outputs = { self, nixos-hardware, ... }@inputs:
    {
      nixosConfigurations = 
        let
          mkNixosSystem = import lib/mkNixosSystem.nix inputs;
        in
          with nixos-hardware.nixosModules; {
            x260 = mkNixosSystem lenovo-thinkpad-x260 hosts/x260.nix;
            acer = mkNixosSystem {} hosts/acer.nix;
          };
    };
}