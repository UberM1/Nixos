{lib, ...}: {
  programs.nixvim.plugins.telescope = {
    enable = lib.mkDefault true;
    extensions = {
      fzf-native = {
        enable = true;
        settings = {
          fuzzy = true;
          override_generic_sorter = true;
          override_file_sorter = true;
          case_mode = "smart_case";
        };
      };
    };
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      "<leader>fb" = "buffers";
      "<leader>fh" = "help_tags";
      "<leader>fo" = "oldfiles";
      "<leader>fc" = "grep_string";
      "<leader>fm" = "marks";
      "<leader>fr" = "registers";
      "<leader>fk" = "keymaps";
      "<leader>fs" = "lsp_document_symbols";
      "<leader>fS" = "lsp_workspace_symbols";
    };
    settings = {
      defaults = {
        file_ignore_patterns = [
          "node_modules"
          "%.git/"
          "dist"
          "build"
          "target"
        ];
        layout_config = {
          horizontal = {
            prompt_position = "top";
            preview_width = 0.55;
          };
          vertical = {
            mirror = false;
          };
          width = 0.87;
          height = 0.80;
          preview_cutoff = 120;
        };
        sorting_strategy = "ascending";
      };
    };
  };
}
