{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    opencode
    bluetuith
    pulsemixer
    tree
    fzf
    home-manager
    curl
    wget
    fzf
    ripgrep
    htop
    jq
    doggo
    alejandra
  ];
}
