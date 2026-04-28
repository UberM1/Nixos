{pkgs, ...}: {
  programs.rbenv = {
    enable = true;
    enableZshIntegration = true;
    plugins = [
      {
        name = "ruby-build";
        src = pkgs.fetchFromGitHub {
          owner = "rbenv";
          repo = "ruby-build";
          rev = "v20240423";
          hash = "sha256-wF9Oy06HRaESs7Nz+HzVsqzhMQjHUvWRcuhx4cq6U4g=";
        };
      }
    ];
  };
}
