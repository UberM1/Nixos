{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    plugins = with pkgs; [
      rofi-emoji
      rofi-calc
      rofi-bluetooth
      rofi-power-menu
      rofi-power-menu
      rofi-pulse-select
    ];

    theme = "Arc-Dark";

    extraConfig = {
      modi = "drun,run,emoji,calc,filebrowser,window";
      show-icons = false;
      sidebar-mode = true;

      # Display names for modes
      display-drun = "Apps";
      display-run = "Run";
      display-emoji = "Emoji";
      display-calc = "Calc";
      display-filebrowser = "Files";
      display-window = "Window";

      # Format options
      drun-display-format = "{name}";

      # Explicit mode switching with Alt and Ctrl keys
      kb-custom-1 = "Alt+1";
      kb-custom-2 = "Alt+2";
      kb-custom-3 = "Alt+3";
      kb-custom-4 = "Alt+4";
      kb-custom-5 = "Alt+5";
      kb-custom-6 = "Alt+6";
    };
  };
}
