{pkgs, ...}: {
  # Set cursor theme globally via home-manager
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark"; # Options: phinger-cursors-light, phinger-cursors-dark
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Bibata Modern (clean, modern)
  # home.pointerCursor = {
  #   package = pkgs.bibata-cursors;
  #   name = "Bibata-Modern-Classic";  # or "Bibata-Modern-Ice"
  #   size = 24;
  #   gtk.enable = true;
  #   x11.enable = true;
  # };

  # Oreo Cursors (cute, colorful - closest to Moga Candy style)
  # home.pointerCursor = {
  #   package = pkgs.oreo-cursors-plus;
  #   name = "oreo_spark_purple_cursors";  # Multiple colors available
  #   size = 24;
  #   gtk.enable = true;
  #   x11.enable = true;
  # };
}
