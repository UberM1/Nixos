{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    opencode
    cliphist

    wl-color-picker
    wl-clipboard

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
    btop
    alejandra

    fastfetch
    gimp
  ];
}
