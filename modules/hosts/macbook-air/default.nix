{inputs, ...}: let
  system = "aarch64-darwin";
  pkgs = import inputs.nixpkgs-darwin {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  flake.darwinConfigurations.macbook-air = inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs = {inherit inputs;};
    modules = [
      ./configuration.nix
      inputs.determinate.darwinModules.default
      inputs.home-manager.darwinModules.home-manager
      inputs.stylix.darwinModules.stylix
      {
        home-manager = {
          useGlobalPkgs = false;
          useUserPackages = true;
          backupFileExtension = "backup";
          users.matiasuberti = import ./home.nix;
          extraSpecialArgs = {inherit inputs pkgs-unstable;};
          sharedModules = [
            inputs.nixvim.homeModules.nixvim
            inputs.stylix.homeModules.stylix
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [
                (final: prev: {
                  # direnv fish tests get SIGKILL'd by macOS sandbox when building from source
                  direnv = prev.direnv.overrideAttrs (_: {doCheck = false;});
                })
              ];
            }
          ];
        };
      }
    ];
  };
}
