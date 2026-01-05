{
  description = "NixOS configuration";
  inputs = {
    # nixpkgs version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ax Shell - using its own nixpkgs for compatibility
    # ax-shell = {
    #   url = "github:poogas/Ax-Shell";
    #   # Don't follow our nixpkgs - let it use its own unstable version
    # };

    opencode.url = "github:sst/opencode/dev";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    opencode,
    ...
  } @ inputs: {
    nixosConfigurations.ubr = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;}; # Passes inputs to all modules
      modules = [
        ./hosts/default/configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager.sharedModules = [
            nixvim.homeModules.nixvim
          ];
        }
      ];
    };
  };
}
