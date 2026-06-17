{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # discord
    vesktop
    prismlauncher
    pkgs-unstable.lavat
    gamescope
    tor-browser
  ];
}
