_: {
  stylix.targets = {
    rofi.enable = true;
    gtk.enable = true;
    hyprland.enable = true;
    noctalia-shell.enable = true;
    # Qt/KDE theming handled manually in dolphin.nix (kdeglobals generated
    # from stylix colors); stylix's qt target forces qtct which makes KDE
    # apps ignore kdeglobals entirely.
    qt.enable = false;
  };
}
