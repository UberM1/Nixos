{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    policies = {
      Preferences = {
        "security.webauthn.enable_softtoken" = false;
      };
    };
    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
      };
      userChrome = ''
        /* Hide horizontal tab bar when using vertical tabs */
        #TabsToolbar {
          visibility: collapse !important;
        }

        /* Optional: Auto-hide sidebar, show on hover */
        #sidebar-box {
          min-width: 40px !important;
          max-width: 40px !important;
          overflow: hidden !important;
          transition: all 0.2s ease !important;
        }

        #sidebar-box:hover {
          min-width: 250px !important;
          max-width: 250px !important;
        }
      '';
    };
  };

  programs.chromium = {
    enable = true;
  };

  programs.git = {
    settings = {
      user = {
        name = "mubr";
        email = "matias.uberti02@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      safe.directory = "/etc/nixos";
    };
    enable = true;
  };

  home.packages = with pkgs; [
    pkgs-unstable.obsidian
    tor-browser
    claude-code
  ];
}
