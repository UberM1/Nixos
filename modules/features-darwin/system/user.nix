{pkgs, ...}: {
  system.primaryUser = "matiasuberti";

  users.users.matiasuberti = {
    home = "/Users/matiasuberti";
    shell = pkgs.zsh;
    isHidden = false;
  };
}
