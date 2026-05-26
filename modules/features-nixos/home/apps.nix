{pkgs, ...}: {
  programs.chromium.enable = true;

  home.packages = with pkgs; [
    gimp
    resources
    onlyoffice-desktopeditors
  ];
}
