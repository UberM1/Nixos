{
  config,
  pkgs,
  lib,
  ...
}: let
  kittyScrollbackPkg = pkgs.vimPlugins.kitty-scrollback-nvim;
  kittyScrollbackKitten = "${kittyScrollbackPkg}/python/kitty_scrollback_nvim.py";
in {
  programs.kitty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isLinux pkgs.emptyDirectory;
    settings = {
      linux_display_server = "wayland";

      font_family = "JetBrainsMono NF Thin";
      bold_font = "JetBrainsMono NF Bold";
      italic_font = "JetBrainsMono NF Thin Italic";
      bold_italic_font = "JetBrainsMono NF Bold Italic";
      font_size = 11;
      disable_ligatures = "always";
      background_opacity = "0.85";
      background_blur = 20;
      window_padding_width = 0;
      enable_audio_bell = false;
      update_check_interval = 0;
      shell_integration = "enabled";
      placement_strategy = "top-left";
      # resize_in_steps = "yes"; no funciona con hyprland ni con aerospace, porque el gestor re-modifica el tamanio
      # Enable window layouts for splits
      enabled_layouts = "splits,stack";
      # Cursor trail animations
      cursor_trail = 10;
      cursor_trail_start_threshold = 0;
      cursor_trail_decay = "0.01 0.05";

      scrollback_lines = 10000;
      confirm_os_window_close = 2;
      copy_on_select = "clipboard";
      mouse_hide_wait = "3.0";
      # Window border colors
      active_border_color = "#88c0d0";
      inactive_border_color = "#4c566a";

      # kitty-scrollback config
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty";
    };
    keybindings = {
      # Window navigation with Ctrl+hjkl (vim-style)
      "ctrl+h" = "neighboring_window left";
      "ctrl+l" = "neighboring_window right";
      "ctrl+k" = "neighboring_window up";
      "ctrl+j" = "neighboring_window down";

      # Window splits (ensure splits layout is active)
      "ctrl+shift+h" = "launch --location=hsplit --cwd=current";
      # "ctrl+shift+v" = "launch --location=vsplit --cwd=current";

      # Layout management
      "ctrl+shift+enter" = "new_window_with_cwd";

      # Focus/spotlight current window (toggle layout)
      "ctrl+f" = "toggle_layout stack";

      # Tab navigation with Ctrl+numbers
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";
      "ctrl+0" = "goto_tab -1";
    };
    themeFile = "Nord";

    extraConfig = ''
      # kitty-scrollback.nvim Kitten alias
      action_alias kitty_scrollback_nvim kitten ${kittyScrollbackKitten}

      # Browse scrollback buffer in nvim (changed from ctrl+shift+h to avoid conflict)
      map ctrl+shift+b kitty_scrollback_nvim

      # Browse output of the last shell command in nvim
      map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output

      # Show clicked command output in nvim
      mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
    '';
  };

  # Copy custom kittens to kitty config directory
  home.file.".config/kitty/kittens/search.py".source = ../kittens/search.py;
  home.file.".config/kitty/kittens/scroll_mark.py".source = ../kittens/scroll_mark.py;
}
