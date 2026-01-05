{ pkgs, ... }:

{
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Required for Gio.DesktopAppInfo to work properly
  home.packages = with pkgs; [
    gsettings-desktop-schemas
    glib
  ];

  # Set up session variables for GTK apps
  home.sessionVariables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  };
}
