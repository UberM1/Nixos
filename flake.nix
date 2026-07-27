{
  description = "NixOS configuration - dendritic structure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pinned to the exact rev the bastion server was already running when it was
    # migrated out of its own nested flake, so the migration changed nothing.
    # Bump deliberately -- it rebuilds and restarts the entire media stack.
    nixpkgs-bastion.url = "github:NixOS/nixpkgs/549bd84d6279f9852cae6225e372cc67fb91a4c1";

    # Deliberately not following nixpkgs-bastion: the nested flake this was
    # migrated from let nixarr use its own pinned nixpkgs, and a follows here
    # would change what gets built.
    nixarr.url = "github:nix-media-server/nixarr/476ffae2a09911008847dd5a86c18b8cb484d198";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.55.0";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.55.0";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3/hl0.55.0";
      inputs.hyprland.follows = "hyprland";
    };

    scrolloverview = {
      url = "github:yayuuu/hyprland-scroll-overview";
      inputs.hyprland.follows = "hyprland";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      imports = [
        ./modules/hosts/ubr
        ./modules/hosts/macbook-air
        ./modules/hosts/bastion
      ];
    };
}
