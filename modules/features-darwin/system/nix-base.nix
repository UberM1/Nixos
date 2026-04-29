{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    zsh
    alejandra
    home-manager
  ];
}
