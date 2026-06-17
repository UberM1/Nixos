{
  description = "NixOS configuration - dendritic structure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      # Pinned to pre-v5 version - v5 has breaking API changes
      url = "github:noctalia-dev/noctalia-shell/e08b08893e2194c0f6dc172f858e788ba825904d";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia-qs = {
      # Pinned to match noctalia pre-v5
      url = "github:noctalia-dev/noctalia-qs/c918c3eb74f9fb9ef88ddd4649bbfd9a39f93af1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      imports = [
        ./modules/hosts/ubr
        ./modules/hosts/macbook-air
      ];
    };
}
