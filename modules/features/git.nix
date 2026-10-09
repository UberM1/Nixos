_: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mubr";
        email = "matias.uberti02@gmail.com";
      };
      pull.rebase = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      branch.autoSetupMerge = "simple";
      safe.directory = "/etc/nixos";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "base16-stylix";
      line-numbers = true;
      features = "interactive";
      interactive = {
        navigate = true;
        hyperlinks = true;
      };
    };
  };
}
