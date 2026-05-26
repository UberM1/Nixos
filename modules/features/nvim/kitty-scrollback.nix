{lib, ...}: {
  programs.nixvim.plugins.kitty-scrollback = {
    enable = lib.mkDefault true;
    settings = {
      status_window = {
        enabled = true;
        autoclose = false;
        show_timer = true;
      };
      keymaps_enabled = true;
      paste_window = {
        highlight_as_normal_win = false;
        yank_register_enabled = true;
      };
    };
  };
}
