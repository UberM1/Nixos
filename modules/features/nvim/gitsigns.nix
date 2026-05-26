{lib, ...}: {
  programs.nixvim.plugins.gitsigns = {
    enable = lib.mkDefault true;
    settings = {
      signs = {
        add = {text = "│";};
        change = {text = "│";};
        delete = {text = "_";};
        topdelete = {text = "‾";};
        changedelete = {text = "~";};
        untracked = {text = "┆";};
      };
      current_line_blame = true;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "eol";
        delay = 500;
      };
      on_attach = ''
        function(bufnr)
          local gs = package.loaded.gitsigns

          -- Navigation
          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer=bufnr, desc="Next git hunk"})

          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer=bufnr, desc="Previous git hunk"})

          -- Actions
        end
      '';
    };
  };
}
