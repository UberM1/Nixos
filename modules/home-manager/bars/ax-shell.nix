{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ax-shell.homeManagerModules.default
  ];

  programs.ax-shell = {
    enable = true;

    settings = {
      # --- General ---
      wallpapersDir = "/home/ubr/Pictures/wallpapers";
      terminalCommand = "kitty -e";
      datetime12hFormat = false;
      cornersVisible = true;

      # --- Cursor ---
      # Use system cursor from cursor.nix to avoid GTK conflicts
      cursor = {
        package = pkgs.phinger-cursors;
        theme = "phinger-cursors-dark";
        size = 24;
      };

      # --- Bar & Dock ---
      bar = {
        position = "Top";
        theme = "Dense"; # Options: "Pills", "Dense", "Edge"
        centered = true;

        workspace = {
          showNumber = true;
          useChineseNumerals = false;
          hideSpecial = true;
        };

        metrics = {
          disks = ["/"];
        };

        components = {
          button_apps = true;
          systray = true;
          control = true;
          network = true;
          button_tools = true;
          sysprofiles = true;
          button_overview = true;
          ws_container = true;
          battery = false;
          metrics = true;
          language = true;
          date_time = true;
          button_power = true;
        };
      };

      dock = {
        enable = true;
        alwaysOccluded = false;
        iconSize = 28;
        theme = "Pills";
      };

      panel = {
        theme = "Notch"; # Options: "Notch", "Panel"
        position = "Center"; # Options: "Center" (for Notch), "Start", "End" (for Panel)
      };

      # --- Notifications ---
      notifications = {
        position = "Top"; # "Top" or "Bottom"
        limitedAppsHistory = [];
        historyIgnoredApps = [];
      };

      # --- Metrics ---
      metrics = {
        main = {
          cpu = true;
          ram = true;
          disk = true;
          gpu = true;
        };
        small = {
          cpu = true;
          ram = true;
          disk = false;
          gpu = false;
        };
      };

      # --- Dashboard Components ---
      dashboard = {
        components = {
          widgets = true;
          pins = true;
          kanban = true;
          wallpapers = true;
          mixer = true;
        };
      };

      keybindings = {
        restart = {
          prefix = "SUPER ALT";
          suffix = "R";
        };
        axmsg = {
          prefix = "SUPER";
          suffix = "I";
        };
        dash = {
          prefix = "SUPER";
          suffix = "D";
        };
        bluetooth = {
          prefix = "SUPER SHIFT";
          suffix = "B";
        };
        pins = {
          prefix = "SUPER";
          suffix = "P";
        };
        kanban = {
          prefix = "SUPER";
          suffix = "N";
        };
        launcher = {
          prefix = "SUPER";
          suffix = "R";
        };
        cliphist = {
          prefix = "SUPER";
          suffix = "V";
        };
        toolbox = {
          prefix = "SUPER";
          suffix = "B";
        };
        overview = {
          prefix = "SUPER";
          suffix = "TAB";
        };
        wallpapers = {
          prefix = "SUPER";
          suffix = "COMMA";
        };
        randwall = {
          prefix = "SUPER SHIFT";
          suffix = "COMMA";
        };
        mixer = {
          prefix = "SUPER";
          suffix = "M";
        };
        emoji = {
          prefix = "SUPER";
          suffix = "PERIOD";
        };
        power = {
          prefix = "SUPER";
          suffix = "ESCAPE";
        };
        caffeine = {
          prefix = "SUPER SHIFT";
          suffix = "C";
        };
        restart_inspector = {
          prefix = "SUPER CTRL ALT";
          suffix = "B";
        };
      };
    };

    # Autostart Ax-Shell with Hyprland
    autostart = {
      enable = false; # Disabled - we'll start it manually with proper environment
    };
  };

  # Use systemd user service for more reliable startup
  systemd.user.services.ax-shell = {
    Unit = {
      Description = "Ax-Shell Desktop Shell";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      Requisite = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${config.programs.ax-shell.package}/bin/ax-shell";
      Restart = "on-failure";
      RestartSec = "3";
      Environment = [
        "GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      ];
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  # Alternative: Start via Hyprland exec-once (commented out, using systemd instead)
  # wayland.windowManager.hyprland.settings.exec-once = [
  #   "systemctl --user start ax-shell.service"
  # ];
}
