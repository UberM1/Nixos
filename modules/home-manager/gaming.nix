{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    discord
    prismlauncher
    pkgs-unstable.lavat
    gamescope
  ];
}
