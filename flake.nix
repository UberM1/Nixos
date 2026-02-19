{
  description = "NixOS configuration";
  inputs = {
    # nixpkgs version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # nixpkgs unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixvim,
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
