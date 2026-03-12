{
  config,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  imports = [
    ./cursor.nix
    ./hypridle.nix
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    plugins = [
      pkgs.hyprlandPlugins.hy3
      inputs.hyprland-plugins.packages.${system}.hyprexpo
      inputs.hyprland-plugins.packages.${system}.csgo-vulkan-fix
      inputs.hyprland-plugins.packages.${system}.hyprscrolling
    ];

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

      exec-once = [
        "noctalia-shell"
        "sleep 2 && noctalia-shell ipc call wallpaper random"
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
          passes = 2;
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

      # Hyprexpo plugin configuration
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current"; # Center around current workspace
        };
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

      # Noctalia blur on dock peek
      layerrule = [
        "blur on, match:namespace ^(noctalia-dock-peek-.*)$"
      ];

      windowrule = [
        # Smart gaps window rules - non-floating windows
        "border_size 0, match:float 0, match:workspace w[t1]"
        "rounding 0, match:float 0, match:workspace w[t1]"
        "border_size 0, match:float 0, match:workspace w[tg1]"
        "rounding 0, match:float 0, match:workspace w[tg1]"
        "border_size 0, match:float 0, match:workspace f[1]"
        "rounding 0, match:float 0, match:workspace f[1]"

        # Other window rules
        "no_blur on, match:class ^()$, match:title ^()$"
        "immediate on, match:class (Minecraft*)"
        "suppress_event maximize, match:class .*"
        "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"
      ];

      bindel = [
        ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp,exec,brightnessctl s 10%+"
        ",XF86MonBrightnessDown,exec,brightnessctl s 10%-"
      ];

      bindl = [
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPause,exec,playerctl play-pause"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
      ];
    };

    extraConfig = ''
      $terminal = kitty
      $fileManager = dolphin
      $mainMod = SUPER

      # 1. APPLICATIONS
      bind = CTRL ALT,T,exec,$terminal #"Terminal"
      bind = $mainMod,E,exec,$fileManager #"File Manager"
      bind = $mainMod,Space,exec,noctalia-shell ipc call launcher toggle #"App Launcher"

      # 2. WINDOW MANAGEMENT
      bind = $mainMod,Q,killactive, #"Close Window"
      bind = $mainMod,V,togglefloating, #"Toggle Floating"
      bind = $mainMod,P,pseudo, #"Pseudo Tile"
      bind = $mainMod SHIFT_L,D,togglesplit, #"Toggle Split"
      bind = $mainMod,D,swapsplit, #"Swap Split"
      bind = $mainMod,F,fullscreen #"Fullscreen"

      # 3. FOCUS
      bind = $mainMod,h,movefocus,l #"Focus Left"
      bind = $mainMod,j,movefocus,d #"Focus Down"
      bind = $mainMod,k,movefocus,u #"Focus Up"
      bind = $mainMod,l,movefocus,r #"Focus Right"

      # 4. WORKSPACES
      bind = $mainMod,1,workspace,1 #"Workspace 1"
      bind = $mainMod,2,workspace,2 #"Workspace 2"
      bind = $mainMod,3,workspace,3 #"Workspace 3"
      bind = $mainMod,4,workspace,4 #"Workspace 4"
      bind = $mainMod,5,workspace,5 #"Workspace 5"
      bind = $mainMod,6,workspace,6 #"Workspace 6"
      bind = $mainMod,7,workspace,7 #"Workspace 7"
      bind = $mainMod,8,workspace,8 #"Workspace 8"
      bind = $mainMod,9,workspace,9 #"Workspace 9"
      bind = $mainMod,0,workspace,10 #"Workspace 10"

      # 5. MOVE WINDOWS
      bind = $mainMod SHIFT,1,movetoworkspace,1 #"Move to WS 1"
      bind = $mainMod SHIFT,2,movetoworkspace,2 #"Move to WS 2"
      bind = $mainMod SHIFT,3,movetoworkspace,3 #"Move to WS 3"
      bind = $mainMod SHIFT,4,movetoworkspace,4 #"Move to WS 4"
      bind = $mainMod SHIFT,5,movetoworkspace,5 #"Move to WS 5"
      bind = $mainMod SHIFT,6,movetoworkspace,6 #"Move to WS 6"
      bind = $mainMod SHIFT,7,movetoworkspace,7 #"Move to WS 7"
      bind = $mainMod SHIFT,8,movetoworkspace,8 #"Move to WS 8"
      bind = $mainMod SHIFT,9,movetoworkspace,9 #"Move to WS 9"
      bind = $mainMod SHIFT,0,movetoworkspace,10 #"Move to WS 10"

      # 6. SCRATCHPAD
      bind = $mainMod,S,togglespecialworkspace,magic #"Toggle Scratchpad"
      bind = $mainMod SHIFT,S,movetoworkspace,special:magic #"Move to Scratchpad"

      # 7. SCREENSHOTS
      bind = ,PRINT,exec,hyprshot -m output #"Screenshot Monitor"
      bind = $mainMod,PRINT,exec,hyprshot -m window #"Screenshot Window"
      bind = $shiftMod,PRINT,exec,hyprshot -m region #"Screenshot Region"

      # 8. SYSTEM
      bind = $mainMod,M,exit, #"Exit Hyprland"
      bind = $mainMod,Escape,exec,noctalia-shell ipc call lockScreen lock #"Lock Screen"
      bind = $mainMod,T,exec,/home/ubr/scripts/tablet-toggle.sh #"Toggle Tablet Mode"
      bind = $mainMod,grave,hyprexpo:expo,toggle #"Workspace Overview"
      bind = $mainMod,F1,exec,noctalia-shell ipc call plugin:keybind-cheatsheet toggle #"Keybind Cheatsheet"

      bind = $mainMod,mouse_down,workspace,e+1
      bind = $mainMod,mouse_up,workspace,e-1

      bindm = $mainMod,mouse:272,movewindow
      bindm = $mainMod,mouse:273,resizewindow
    '';
  };

  programs.hyprshot = {
    enable = true;
    saveLocation = "$HOME/Pictures/Screenshots";
  };

  home.packages = with pkgs; [
    hypridle
  ];
}
