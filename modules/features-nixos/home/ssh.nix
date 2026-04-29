{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/dssh";
        extraOptions.AddKeysToAgent = "yes";
      };
      "github.com" = {
        identityFile = "~/.ssh/dssh";
      };
    };
  };

  services.ssh-agent.enable = true;
}
