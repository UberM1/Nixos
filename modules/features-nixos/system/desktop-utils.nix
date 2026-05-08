{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencode
    cliphist

    wl-color-picker
    wl-clipboard

    bluetuith
    pulsemixer

    wev
    wtype
    libnotify
  ];
}
