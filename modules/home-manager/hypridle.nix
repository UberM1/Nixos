{
  config,
  pkgs,
  ...
}: {
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "pidof hyprlock || hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        # Dim monitors after 2.5 minutes (via DDC/CI)
        {
          timeout = 150;
          on-timeout = ''
            ddcutil --display 1 getvcp 10 | grep -oP 'current value =\s*\K\d+' > /tmp/brightness_d1
            ddcutil --display 2 getvcp 10 | grep -oP 'current value =\s*\K\d+' > /tmp/brightness_d2
            ddcutil --display 1 setvcp 10 5
            ddcutil --display 2 setvcp 10 5
          '';
          on-resume = ''
            ddcutil --display 1 setvcp 10 $(cat /tmp/brightness_d1 2>/dev/null || echo 100)
            ddcutil --display 2 setvcp 10 $(cat /tmp/brightness_d2 2>/dev/null || echo 100)
          '';
        }
        # Lock screen after 5 minutes
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        # Turn off screen after 5.5 minutes
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Suspend after 10 minutes
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
