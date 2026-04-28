{pkgs, ...}: {
  # GTK theming handled by stylix
  gtk.enable = true;

  home.packages = with pkgs; [
    gsettings-desktop-schemas
    glib
  ];

  home.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  };
}
