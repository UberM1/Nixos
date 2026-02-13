{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hyprlock.nix
    ./cursor.nix
    # ./hypridle.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitor configuration
      monitor = [
        "DP-1,1920x1080@180,0x0,1"
        "HDMI-A-1,1920x1080@74.97,1920x0,1"
        ",preferred,auto,1"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # Programs
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi -show drun";
      "$mainMod" = "SUPER";

      # Autostart
      exec-once = [
        "swww-daemon"
        "ashell"
      ];

      # General settings
      general = {
        gaps_in = 2;
        gaps_out = 3;
        border_size = 1;
        "col.active_border" = "rgba(88c0d0ee)";
        "col.inactive_border" = "rgba(eceff4af)";
        resize_on_border = true;
        allow_tearing = true;
        layout = "dwindle";
      };

      # Cursor settings
      cursor = {
        no_hardware_cursors = 1;
      };

      # Decoration settings
      decoration = {
        rounding = 3;
        rounding_power = 4;
        active_opacity = 1.0;
        inactive_opacity = 1;
        dim_inactive = false;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global,1,10,default"
          "border,1,5.39,easeOutQuint"
          "windows,1,4.79,easeOutQuint"
          "windowsIn,1,4.1,easeOutQuint,popin 87%"
          "windowsOut,1,1.49,linear,popin 87%"
          "fadeIn,1,1.73,almostLinear"
          "fadeOut,1,1.46,almostLinear"
          "fade,1,3.03,quick"
          "layers,1,3.81,easeOutQuint"
          "layersIn,1,4,easeOutQuint,fade"
          "layersOut,1,1.5,linear,fade"
          "fadeLayersIn,1,1.79,almostLinear"
          "fadeLayersOut,1,1.39,almostLinear"
          "workspaces,1,1.94,almostLinear,fade"
          "workspacesIn,1,1.21,almostLinear,fade"
          "workspacesOut,1,1.94,almostLinear,fade"
        ];
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc settings
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      # Input settings
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };

      # Device configurations
      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
        {
          name = "huion-huion-tablet_h640p";
          output = "DP-1";
        }
      ];

      # Workspace configuration
      workspace = [
        # Smart gaps configuration
        "w[t1],gapsout:0,gapsin:0"
        "w[tg1],gapsout:0,gapsin:0"
        "f[1],gapsout:0,gapsin:0"

        # Workspace-monitor assignments
        "1,monitor:DP-1,default:true"
        "2,monitor:DP-1"
        "3,monitor:DP-1"
        "4,monitor:DP-1"
        "5,monitor:DP-1"
        "6,monitor:HDMI-A-1"
        "7,monitor:HDMI-A-1"
        "8,monitor:HDMI-A-1"
        "9,monitor:HDMI-A-1"
        "10,monitor:HDMI-A-1"
      ];

      # Window rules
      windowrulev2 = [
        # Smart gaps window rules
        "bordersize 0,floating:0,onworkspace:w[t1]"
        "rounding 0,floating:0,onworkspace:w[t1]"
        "bordersize 0,floating:0,onworkspace:w[tg1]"
        "rounding 0,floating:0,onworkspace:w[tg1]"
        "bordersize 0,floating:0,onworkspace:f[1]"
        "rounding 0,floating:0,onworkspace:f[1]"

        # Other window rules
        "noblur,class:^()$,title:^()$"
        "immediate,class:(Minecraft*)"
        "suppressevent maximize,class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Keybindings
      bind =
        # config.programs.ax-shell.hyprlandBinds
        # ++
        [
          # Basic window management
          "$mainMod,Q,killactive,"
          "CTRL ALT,T,exec,$terminal"
          "$mainMod,M,exit,"
          "$mainMod,E,exec,$fileManager"
          "$mainMod,V,togglefloating,"
          "$mainMod,Space,exec,$menu"
          "$mainMod,P,pseudo,"
          "$mainMod SHIFT_L,D,togglesplit,"
          "$mainMod,D,swapsplit,"
          "$mainMod,F,fullscreen"

          # Focus movement (vim-style)
          "$mainMod,h,movefocus,l"
          "$mainMod,j,movefocus,d"
          "$mainMod,k,movefocus,u"
          "$mainMod,l,movefocus,r"

          # Workspace switching
          "$mainMod,1,workspace,1"
          "$mainMod,2,workspace,2"
          "$mainMod,3,workspace,3"
          "$mainMod,4,workspace,4"
          "$mainMod,5,workspace,5"
          "$mainMod,6,workspace,6"
          "$mainMod,7,workspace,7"
          "$mainMod,8,workspace,8"
          "$mainMod,9,workspace,9"
          "$mainMod,0,workspace,10"

          # Move windows to workspaces
          "$mainMod SHIFT,1,movetoworkspace,1"
          "$mainMod SHIFT,2,movetoworkspace,2"
          "$mainMod SHIFT,3,movetoworkspace,3"
          "$mainMod SHIFT,4,movetoworkspace,4"
          "$mainMod SHIFT,5,movetoworkspace,5"
          "$mainMod SHIFT,6,movetoworkspace,6"
          "$mainMod SHIFT,7,movetoworkspace,7"
          "$mainMod SHIFT,8,movetoworkspace,8"
          "$mainMod SHIFT,9,movetoworkspace,9"
          "$mainMod SHIFT,0,movetoworkspace,10"

          # Special workspace (scratchpad)
          "$mainMod,S,togglespecialworkspace,magic"
          "$mainMod SHIFT,S,movetoworkspace,special:magic"

          # Workspace scrolling
          "$mainMod,mouse_down,workspace,e+1"
          "$mainMod,mouse_up,workspace,e-1"

          # Screenshots (hyprshot)
          ",PRINT,exec,hyprshot -m output"
          "$mainMod,PRINT,exec,hyprshot -m window"
          "$shiftMod,PRINT,exec,hyprshot -m region"

          # Screen locking
          "$mainMod,Escape,exec,hyprlock"

          # Tablet toggle script
          "$mainMod,T,exec,/home/ubr/scripts/tablet-toggle.sh"
        ];

      # Media key bindings (with repeat)
      bindel = [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp,exec,brightnessctl s 10%+"
        ",XF86MonBrightnessDown,exec,brightnessctl s 10%-"
      ];

      # Media control bindings (no repeat)
      bindl = [
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPause,exec,playerctl play-pause"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod,mouse:272,movewindow"
        "$mainMod,mouse:273,resizewindow"
      ];
    };
  };

  programs.hyprshot = {
    enable = true;
    saveLocation = "$HOME/Pictures/Screenshots";
  };

  # Install swww package
  home.packages = with pkgs; [
    swww
    hypridle
  ];
}
