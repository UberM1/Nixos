{lib, ...}: {
  programs.nixvim.plugins.neo-tree = {
    enable = lib.mkDefault true;
    settings = {
      close_if_last_window = true;
      enable_git_status = true;
      enable_diagnostics = true;
      window = {
        width = 30;
        auto_expandWidth = false;
        mappings = {
          "<esc>" = "close_window";
          "a" = {
            command = "add";
            config = {
              show_path = "none";
            };
          };
          "A" = "add_directory";
          "d" = "delete";
          "r" = "rename";
          "y" = "copy_to_clipboard";
          "x" = "cut_to_clipboard";
          "p" = "paste_from_clipboard";
          "c" = "copy";
          "m" = "move";
          "q" = "close_window";
        };
      };
      buffers = {
        follow_current_file = {
          enabled = true;
        };
        window = {
          mappings = {
            "<esc>" = "close_window";
            "q" = "close_window";
          };
        };
      };
      filesystem = {
        follow_current_file = {
          enabled = true;
        };
        filtered_items = {
          hide_dotfiles = false;
          hide_gitignored = false;
        };
        use_libuv_file_watcher = true;
        window = {
          mappings = {
            "<esc>" = "close_window";
            "a" = {
              command = "add";
              config = {
                show_path = "none";
              };
            };
            "A" = "add_directory";
            "d" = "delete";
            "r" = "rename";
            "y" = "copy_to_clipboard";
            "x" = "cut_to_clipboard";
            "p" = "paste_from_clipboard";
            "c" = "copy";
            "m" = "move";
            "q" = "close_window";
          };
        };
      };
    };
  };
}
