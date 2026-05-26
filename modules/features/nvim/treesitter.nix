{lib, ...}: {
  programs.nixvim.plugins.treesitter = {
    enable = lib.mkDefault true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
