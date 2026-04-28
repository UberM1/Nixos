{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.steam.enable = true;

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
  };

  services.netbird = {
    enable = true;
    package = pkgs-unstable.netbird;
  };

  services.tor.enable = true;
}
