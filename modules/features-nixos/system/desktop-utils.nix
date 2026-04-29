{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencode
    cliphist

    wl-color-picker
    wl-clipboard

    bluetuith
    pulsemixer
    home-manager
    resources

    fastfetch
    gimp
    wev
    wtype
    libnotify
  ];
}
