{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    steam
    prismlauncher
  ];
}
