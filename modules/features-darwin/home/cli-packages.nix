{pkgs, ...}: {
  home.packages = with pkgs; [
    git
    git-lfs
    lsd
    gh
    fastfetch
    pscale
    procs
  ];
}
