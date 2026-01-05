{
  config,
  pkgs,
  ...
}: {
  programs.ashell = {
    enable = true;
    settings = {
      log_level = "warn";
      outputs = "All";
      position = "Top";
      app_launcher_cmd = "rofi -show drun";
      clipboard_cmd = "cliphist list | rofi -dmenu | cliphist decode | wl-copy";

      modules = {
        left = ["AppLauncher" "Workspaces"];
        center = ["WindowTitle"];
        right = ["SystemInfo" "Tray" "Clock" "Privacy" "Settings"];
      };

      workspaces = {
        visibility_mode = "All";
        enable_workspace_filling = true;
        max_workspaces = 10;
      };

      window_title = {
        truncate_title_after_length = 80;
      };

      settings = {
        lock_cmd = "hyprlock";
        audio_sinks_more_cmd = "pavucontrol -t 3";
        audio_sources_more_cmd = "pavucontrol -t 4";
        wifi_more_cmd = "nm-connection-editor";
        bluetooth_more_cmd = "blueman-manager";
      };

      appearance = {
        style = "Solid";
        opacity = 1.0;
        font_name = "JetBrainsMono Nerd Font";
        primary_color = "#88c0d0";
        success_color = "#a3be8c";
        text_color = "#eceff4";

        danger_color = {
          base = "#bf616a";
          weak = "#d08770";
        };

        background_color = {
          base = "#2e3440";
          weak = "#3b4252";
          strong = "#434c5e";
        };

        secondary_color = {
          base = "#2e3440";
        };
      };
    };
  };
}
