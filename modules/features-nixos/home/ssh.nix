{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentityFile = "~/.ssh/dssh";
      };
      "github.com".IdentityFile = "~/.ssh/dssh";
    };
  };

  services.ssh-agent.enable = true;
}
