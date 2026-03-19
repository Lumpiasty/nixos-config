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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-sweep = {
      url = "github:jzbor/nix-sweep/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    peerix = {
      url = "git+ssh://git@gitea.lumpiasty.xyz/Lumpiasty/peerix.git"; # fork of github:sophronesis/peerix
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            gaming-pc = mkNixosSystem {} hosts/gaming-pc.nix;
          };
    };
}