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
