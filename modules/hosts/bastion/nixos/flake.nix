{
  description = "Bastion server NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixarr.url = "github:nix-media-server/nixarr";
  };

  outputs = { self, nixpkgs, nixarr }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.bastion-server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixarr.nixosModules.default
          ./configuration.nix
          ./services.nix
        ];
      };
    };
}
