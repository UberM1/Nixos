{pkgs, ...}: {
  imports = [
    ../../features-darwin/system/defaults.nix
    ../../features-darwin/system/homebrew.nix
    ../../features-darwin/system/user.nix
    ../../features-darwin/system/nix-base.nix
    ../../features-darwin/system/kubernetes.nix
    ../../features-darwin/system/terraform.nix
    ../../features-darwin/system/databases.nix
    ../../features-darwin/system/ruby.nix
    ../../features-darwin/system/golang.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  nix.enable = false;
}
