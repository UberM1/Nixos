{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Cross-platform features (shared with NixOS)
    ../../features/stylix.nix
    ../../features/zsh.nix
    ../../features/nvim.nix
    ../../features/kitty.nix
    ../../features/shell-tools.nix
    ../../features/apps.nix
    ../../features/git.nix
    ../../features/cli-packages.nix

    # Darwin-only home features
    ../../features-darwin/home/aerospace.nix
    ../../features-darwin/home/sketchybar.nix
    ../../features-darwin/home/cli-packages.nix
    ../../features-darwin/home/ruby.nix
  ];

  home.username = lib.mkForce "matiasuberti";
  home.homeDirectory = lib.mkForce "/Users/matiasuberti";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.activation.installGitAccount = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.local/bin"
    if [ ! -d "$HOME/.npm/node_modules/git-account" ]; then
      ${pkgs.nodejs}/bin/npm install --prefix "$HOME/.npm" git-account
    fi
    ln -sf "$HOME/.npm/node_modules/.bin/git-account" "$HOME/.local/bin/git-account"
  '';

  home.sessionPath = ["$HOME/.local/bin"];
}
