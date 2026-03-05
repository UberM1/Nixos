{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.caelestia = {
    enable = false;  # Disabled - using noctalia instead
    cli.enable = true;

    settings = {
      general = {
        position = "top";
      };
      bar = {
        position = "top";
      };
      launcher = {
        file_manager = "dolphin";
      };
      wallpaper = {
        enable = false;  # Disable built-in wallpaper management, use swww instead
      };
    };
  };
}
