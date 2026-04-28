{...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mubr";
        email = "matias.uberti02@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      safe.directory = "/etc/nixos";
    };
  };
}
