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

    hyprland.url = "github:hyprwm/Hyprland/v0.53.0";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.53.0";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3/hl0.53.0";
      inputs.hyprland.follows = "hyprland";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
            inputs.caelestia-shell.homeManagerModules.default
            inputs.noctalia.homeModules.default
            inputs.stylix.homeModules.stylix
          ];
        }
      ];
    };
  };
}
