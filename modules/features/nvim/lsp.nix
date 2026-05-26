{lib, ...}: {
  programs.nixvim.plugins.lsp = {
    enable = lib.mkDefault true;
    servers = {
      nixd = {
        enable = true;
        settings = {
          nixpkgs = {
            expr = "import <nixpkgs> { }";
          };
          formatting = {
            command = ["alejandra"];
          };
        };
      };
      lua_ls.enable = true;
      jsonls.enable = true;
      yamlls = {
        enable = true;
        autostart = false;
      };
      solargraph.enable = true;
      gopls.enable = true;
      helm_ls.enable = true;
      pylsp.enable = true;
      clangd.enable = true;
      terraformls.enable = true;
    };

    keymaps = {
      lspBuf = {
        "gd" = "definition";
        "gr" = "references";
        "gD" = "declaration";
        "gI" = "implementation";
        "gt" = "type_definition";
        "K" = "hover";
        "<leader>ca" = "code_action";
        "<leader>cr" = "rename";
        "<F2>" = "rename";
      };
      diagnostic = {
        "<leader>cd" = "open_float";
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };
    };
  };
}
