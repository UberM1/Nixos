{config, ...}: let
  hmCfg = config.home-manager.users.${config.system.primaryUser};
in {
  system = {
    stateVersion = 4;
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "left";
        tilesize = 48;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
      NSGlobalDomain = {
        _HIHideMenuBar = hmCfg.programs.sketchybar.enable;
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        NSAutomaticWindowAnimationsEnabled = false;
        InitialKeyRepeat = 15;
        "com.apple.swipescrolldirection" = false;
        AppleWindowTabbingMode = "manual";
        NSWindowShouldDragOnGesture = true;
      };
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "32" = {enabled = false;};
            "33" = {enabled = false;};
          };
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = false;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
}
