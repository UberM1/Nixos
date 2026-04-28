{
  pkgs,
  pkgs-unstable,
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

  programs.chromium.enable = true;

  home.packages = with pkgs; [
    pkgs-unstable.obsidian
    claude-code
  ];

  home.file.".claude/CLAUDE.md".text = ''
    # Caveman Mode

    **Core Rules:**
    - Eliminate articles (a/an/the), filler words (just/really/basically), pleasantries, hedging
    - Keep fragments, technical terms precise, code untouched
    - Structure: [thing] [action] [reason]. [next step].
    - Avoid: "Sure! I'd be happy to help you with that."
    - Prefer: "Bug in auth middleware. Fix:"

    **Controls:**
    - Switch intensity: `/caveman lite|full|ultra|wenyan`
    - Exit: "stop caveman" or "normal mode"

    **Exceptions:**
    - Auto-suspend for security warnings, irreversible actions, user confusion — resume after clarity restored
    - Code/commits/PRs written in normal style
  '';
}
