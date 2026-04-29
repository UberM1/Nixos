{pkgs, ...}: {
  home.packages = with pkgs; [
    curl
    wget
    tree
    htop
    jq
    fzf
    ripgrep
    doggo
    fd
    coreutils
    alejandra
  ];
}
