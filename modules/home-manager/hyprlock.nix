{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    
    settings = {
      # BACKGROUND
      background = [
        {
          monitor = "";
          path = "~/Pictures/wallpapers/ign-cityrainother.png";
          blur_passes = 2;
          blur_size = 3;
          contrast = 1.0;
          brightness = 0.5;
          vibrancy = 0.0;
          vibrancy_darkness = 0.0;
        }
      ];

      # GENERAL
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
        hide_cursor = true;
      };

      # INPUT FIELD
      input-field = [
        {
          monitor = "";
          size = "256, 48";
          outline_thickness = 0;
          dots_size = 0.2;
          dots_spacing = 0.5;
          dots_center = true;
          outer_color = "0x00000000";
          inner_color = "rgb(0, 0, 0)";
          font_color = "rgb(59, 66, 82)";
          fail_color = "rgb(191, 97, 106)";
          check_color = "rgb(59, 66, 82)";
          capslock_color = "rgb(191, 97, 106)";
          fade_on_empty = false;
          font_family = "Iosevka Nerd Font";
          placeholder_text = "";
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
          shadow_size = 5;
          shadow_boost = 0.5;
        }
      ];

      # LABELS
      label = [
        # TIME
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M:%S")"'';
          color = "rgb(129, 161, 193)";
          font_size = 50;
          font_family = "Iosevka Nerd Font Bold";
          position = "0, 200";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
          shadow_size = 5;
          shadow_boost = 0.5;
        }
        # USER
        {
          monitor = "";
          text = ''cmd[update:1000] echo "Welcome $USER !"'';
          color = "rgb(129, 161, 193)";
          font_size = 14;
          font_family = "Iosevka Nerd Font Bold";
          position = "0, -55";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
          shadow_size = 5;
          shadow_boost = 0.5;
        }
        # FORTUNE (optional - only if fortune is installed)
        {
          monitor = "";
          text = ''cmd[update:3600000] fortune 2>/dev/null || echo "Lock screen"'';
          text_align = "left";
          color = "rgb(129, 161, 193)";
          font_size = 9;
          font_family = "Iosevka Nerd Font Italic";
          position = "10, 20";
          halign = "left";
          valign = "bottom";
          size = "30, 0";
        }
      ];

      # PICTURE (commented out as in original)
      # image = [
      #   {
      #     path = ".face.icon";
      #     size = 150;
      #     position = "0, 50";
      #     halign = "center";
      #     valign = "center";
      #     border_size = 3;
      #     border_color = "0xff81A1C1";
      #     shadow_passes = 1;
      #     shadow_size = 5;
      #     shadow_boost = 0.5;
      #   }
      # ];
    };
  };

  # Install required fonts
  home.packages = with pkgs; [
    iosevka-bin
    nerd-fonts.iosevka
    fortune
  ];
}
