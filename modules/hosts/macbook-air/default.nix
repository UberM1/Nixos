# Placeholder for macbook-air darwin configuration
# Uncomment and configure when ready
#
# {inputs, ...}: {
#   flake.darwinConfigurations.macbook-air = inputs.nix-darwin.lib.darwinSystem {
#     system = "aarch64-darwin";
#     specialArgs = {inherit inputs;};
#     modules = [
#       ./configuration.nix
#       inputs.home-manager.darwinModules.home-manager
#       {
#         home-manager = {
#           useGlobalPkgs = true;
#           useUserPackages = true;
#           users.matiasuberti = import ./home.nix;
#           extraSpecialArgs = {inherit inputs;};
#           sharedModules = [
#             inputs.nixvim.homeModules.nixvim
#             inputs.stylix.homeModules.stylix
#           ];
#         };
#       }
#     ];
#   };
# }
{...}: {}
