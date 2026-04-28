{inputs, ...}: let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  flake.nixosConfigurations.ubr = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs pkgs-unstable;};
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = false;
          useUserPackages = true;
          backupFileExtension = "hm_backup";
          users.ubr = import ./home.nix;
          extraSpecialArgs = {inherit inputs pkgs pkgs-unstable;};
          sharedModules = [
            inputs.nixvim.homeModules.nixvim
            inputs.stylix.homeModules.stylix
            inputs.noctalia.homeModules.default
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      }
    ];
  };
}
