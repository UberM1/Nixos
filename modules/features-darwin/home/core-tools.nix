{pkgs, ...}: {
  home.packages = with pkgs; [
    git
    git-lfs

    curl
    wget

    tree
    htop
    lsd
    jq
    gh
    bat

    fastfetch
    pscale

    claude-code
    fzf
    ripgrep
    alejandra
    fd
    coreutils
    doggo
    procs
  ];
}
