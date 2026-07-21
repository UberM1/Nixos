{pkgs, ...}: {
  home.packages = with pkgs; [
    brightnessctl
    cliphist
    wl-clipboard
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = false;

    settings = {
      audio.enable_overdrive = false;

      brightness.enable_ddcutil = true;

      location = {
        address = "Rosario";
        auto_locate = false;
      };

      lockscreen.enabled = true;

      nightlight = {
        enabled = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      notification.enable_daemon = false;

      osd.position = "top_right";

      shell = {
        avatar_path = "/home/ubr/.face";
        clipboard_enabled = true;
        date_format = "%A, %x";
        font_family = "JetBrainsMono Nerd Font Mono";
        time_format = "{:%H:%M}";
        animation = {
          enabled = true;
          speed = 1.3;
        };
        panel = {
          control_center_placement = "attached";
          launcher_placement = "centered";
          session_placement = "attached";
          shadow = false;
          wallpaper_placement = "attached";
        };
        screen_corners.size = 100;
      };

      theme = {
        builtin = "Eldritch";
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-fruit-salad";
      };

      wallpaper = {
        directory = "/home/ubr/Pictures/wallpapers/nord";
        enabled = true;
        fill_mode = "crop";
        transition_duration = 1500;
      };

      weather = {
        effects = true;
        enabled = true;
        unit = "celsius";
      };

      bar.main = {
        auto_hide = false;
        capsule = true;
        center = ["workspaces"];
        end = ["tray" "volume" "bluetooth" "brightness" "notifications" "clock"];
        font_family = "JetBrainsMono Nerd Font";
        margin_edge = 0;
        margin_ends = 0;
        margin_h = 4;
        margin_v = 4;
        padding = 13;
        position = "top";
        radius = 0;
        reserve_space = true;
        start = ["control-center"];
        thickness = 35;
        widget_spacing = 5;
      };

      dock = {
        auto_hide = true;
        enabled = true;
        icon_size = 32;
        position = "bottom";
        radius = 0;
        reserve_space = false;
      };

      control_center.shortcuts = [
        {type = "wifi";}
        {type = "bluetooth";}
        {type = "wallpaper";}
        {type = "power_profile";}
        {type = "caffeine";}
        {type = "nightlight";}
      ];

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = ["lockscreen-login-box@DP-1" "lockscreen-login-box@HDMI-A-1"];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          "lockscreen-login-box@DP-1" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 957.0;
            output = "DP-1";
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
          "lockscreen-login-box@HDMI-A-1" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 957.0;
            output = "HDMI-A-1";
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
        };
      };

      widget = {
        active_window = {
          capsule_padding = 10.0;
          display = "text_only";
          icon_size = 33.0;
        };
        clock = {
          format = "{:%H:%M %a, %b %d}";
          tooltip_format = "{:%A, %B %d, %Y}";
        };
        volume = {
          middle_command = "pwvucontrol || pavucontrol";
        };
      };
    };
  };
}
