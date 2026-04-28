{pkgs, ...}: {
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
    resources
    alejandra

    fastfetch
    gimp
    wev
    wtype
    libnotify
  ];
}
