{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
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
    obsidian
    tor-browser
    claude-code
    inputs.opencode.packages.${pkgs.system}.default
  ];

  # programs.opencode.enable = true; does not work not well builded
}
