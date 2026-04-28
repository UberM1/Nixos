{pkgs, ...}: {
  programs.kitty = {
    # On NixOS, kitty is installed system-wide
    package = pkgs.emptyDirectory;
    settings = {
      linux_display_server = "wayland";
    };
  };
}
