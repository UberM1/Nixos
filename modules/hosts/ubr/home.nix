{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Cross-platform features
    ../../features/stylix.nix
    ../../features/zsh.nix
    ../../features/nvim.nix
    ../../features/kitty.nix
    ../../features/shell-tools.nix
    ../../features/apps.nix
    ../../features/git.nix

    # NixOS-only home features
    ../../features-nixos/home/hypr
    ../../features-nixos/home/gaming.nix
    ../../features-nixos/home/hacking.nix
    ../../features-nixos/home/work-pkgs.nix
    ../../features-nixos/home/rofi.nix
    ../../features-nixos/home/gtk.nix
    ../../features-nixos/home/dolphin.nix
    ../../features-nixos/home/lutris.nix
    ../../features-nixos/home/scripts.nix
    ../../features-nixos/home/bars/noctalia-shell.nix
  ];

  home.username = "ubr";
  home.homeDirectory = "/home/ubr";
  home.stateVersion = "25.11";

  home.packages = [];
  home.file = {};
  home.sessionVariables = {};

  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/dssh";
        extraOptions.AddKeysToAgent = "yes";
      };
      "github.com" = {
        identityFile = "~/.ssh/dssh";
      };
    };
  };

  services.ssh-agent.enable = true;
}
