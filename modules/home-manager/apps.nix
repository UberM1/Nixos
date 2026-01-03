{ config, pkgs, ... }:

{
  programs.git  = {
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
  ];
}
