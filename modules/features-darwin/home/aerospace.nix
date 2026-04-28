{...}: {
  programs.aerospace = {
    enable = true;
    userSettings = {
      enable-normalization-flatten-containers = false;
      enable-normalization-opposite-orientation-for-nested-containers = false;

      mode.main.binding = {
        alt-h = "focus --boundaries-action wrap-around-the-workspace left";
        alt-j = "focus --boundaries-action wrap-around-the-workspace down";
        alt-k = "focus --boundaries-action wrap-around-the-workspace up";
        alt-l = "focus --boundaries-action wrap-around-the-workspace right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-f = "fullscreen";

        alt-s = "layout v_accordion";
        alt-w = "layout h_accordion";
        alt-e = "layout tiles horizontal vertical";

        alt-shift-space = "layout floating tiling";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        alt-shift-1 = ["move-node-to-workspace 1" "workspace 1"];
        alt-shift-2 = ["move-node-to-workspace 2" "workspace 2"];
        alt-shift-3 = ["move-node-to-workspace 3" "workspace 3"];
        alt-shift-4 = ["move-node-to-workspace 4" "workspace 4"];
        alt-shift-5 = ["move-node-to-workspace 5" "workspace 5"];
        alt-shift-6 = ["move-node-to-workspace 6" "workspace 6"];
        alt-shift-7 = ["move-node-to-workspace 7" "workspace 7"];
        alt-shift-8 = ["move-node-to-workspace 8" "workspace 8"];
        alt-shift-9 = ["move-node-to-workspace 9" "workspace 9"];
        alt-shift-0 = ["move-node-to-workspace 10" "workspace 10"];

        alt-shift-c = "reload-config";
        alt-q = "close --quit-if-last-window";
        alt-r = "mode resize";
      };

      workspace-to-monitor-force-assignment = {
        "1" = "secondary";
        "2" = "secondary";
        "3" = "secondary";
        "4" = "secondary";
        "5" = "secondary";
        "6" = "main";
        "7" = "main";
        "8" = "main";
        "9" = "main";
        "10" = "main";
      };

      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}
