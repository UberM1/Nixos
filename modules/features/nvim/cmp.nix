{lib, ...}: {
  programs.nixvim.plugins = {
    cmp = {
      enable = lib.mkDefault true;
      settings = {
        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };
        sources = [
          {name = "nvim_lsp";}
          {name = "buffer";}
          {name = "path";}
          {name = "luasnip";}
        ];
        formatting = {
          format = ''
            function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                buffer = "[Buffer]",
                path = "[Path]",
                luasnip = "[Snip]",
              })[entry.source.name]
              return vim_item
            end
          '';
        };
      };
    };
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    luasnip.enable = true;
  };
}
