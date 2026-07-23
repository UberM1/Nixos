{pkgs, pkgs-unstable, ...}: {
  home.packages = with pkgs; [
    git
    git-lfs
    lsd
    gh
    procs
    mas
    zstd
    shared-mime-info
    mysql80
    pkgs-unstable.colima
    docker_29
    vscode
    google-chrome
  ];
}
