{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.ghostty = {
    enable = true;
    settings = {
      # Font configuration
      font-family = "JetBrainsMono NF Thin";
      font-family-bold = "JetBrainsMono NF Bold";
      font-family-italic = "JetBrainsMono NF Thin Italic";
      font-family-bold-italic = "JetBrainsMono NF Bold Italic";
      font-size = 11;

      # Disable ligatures
      font-feature = ["-liga" "-calt"];

      # Window appearance
      background-opacity = 0.85;
      background-blur = true;
      window-padding-x = 0;
      window-padding-y = "0,18";

      # Bell (disable audio and system bell)
      bell-features = "no-system,no-audio";

      # Shell integration
      shell-integration = "detect";

      # Scrollback
      scrollback-limit = 10000;

      # Clipboard
      copy-on-select = "clipboard";

      # Mouse
      mouse-hide-while-typing = true;

      # Window close confirmation
      confirm-close-surface = true;

      # Theme (Nord)
      theme = "Nord";

      # Focus indicator - dim unfocused splits (like kitty's inactive border)
      unfocused-split-opacity = 0.85;

      # Split divider color (matches kitty active_border_color)
      split-divider-color = "#88c0d0";

      # GTK/Tab settings
      gtk-tabs-location = "top";
      gtk-wide-tabs = false;
      gtk-titlebar = true;

      # Keybindings
      keybind = [
        # Window navigation with Ctrl+hjkl (vim-style)
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
        "ctrl+k=goto_split:up"
        "ctrl+j=goto_split:down"

        # Vertical split (new pane to the right) - like ctrl+shift+enter in kitty
        "ctrl+shift+enter=new_split:right"

        # Horizontal split (new pane below) - like ctrl+shift+h in kitty
        "ctrl+shift+h=new_split:down"

        # Focus/zoom current split (like toggle_layout stack in kitty)
        "ctrl+f=toggle_split_zoom"

        # New tab
        "ctrl+shift+t=new_tab"

        # Tab navigation with Ctrl+numbers
        "ctrl+1=goto_tab:1"
        "ctrl+2=goto_tab:2"
        "ctrl+3=goto_tab:3"
        "ctrl+4=goto_tab:4"
        "ctrl+5=goto_tab:5"
        "ctrl+6=goto_tab:6"
        "ctrl+7=goto_tab:7"
        "ctrl+8=goto_tab:8"
        "ctrl+9=goto_tab:9"
        "ctrl+0=last_tab"
      ];
    };
  };
}
