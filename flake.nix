{
  description = "NixOS configuration - dendritic structure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Bastion keeps its own nixpkgs input rather than sharing the desktop hosts'
    # so the media server can be rebuilt on its own schedule: updating a laptop
    # should not restart Jellyfin mid-playback. Both track 26.05 today, so the
    # separation costs an extra evaluation and buys independent timing.
    #
    # This was frozen at an exact rev (549bd84) while the host was migrated out
    # of a standalone nested flake, so the evaluated system could be proven
    # byte-identical before and after. That verification is done; tracking the
    # release branch again is what keeps security fixes flowing.
    #
    # Bump deliberately -- it rebuilds and restarts the entire media stack, and
    # comin deploys it automatically. Push to `testing-bastion` first.
    nixpkgs-bastion.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Deliberately not following nixpkgs-bastion: nixarr pins the nixpkgs it is
    # tested against, and a follows here would build its packages against a
    # different tree than upstream CI does.
    nixarr.url = "github:nix-media-server/nixarr";

    # GitOps auto-deploy for the bastion server. Not in nixpkgs.
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs-bastion";
    };

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

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        checks = {
          format =
            pkgs.runCommand "check-format" {nativeBuildInputs = [pkgs.alejandra];}
            "alejandra --check ${./.} && touch $out";
          statix =
            pkgs.runCommand "check-statix" {nativeBuildInputs = [pkgs.statix];}
            "statix check -c ${./statix.toml} ${./.} && touch $out";
          deadnix =
            pkgs.runCommand "check-deadnix" {nativeBuildInputs = [pkgs.deadnix];}
            "deadnix --fail ${./.} && touch $out";
        };
      };

      imports = [
        ./modules/hosts/ubr
        ./modules/hosts/macbook-air
        ./modules/hosts/bastion
      ];
    };
}
