{lib, ...}: {
  programs.nixvim.plugins.conform-nvim = {
    enable = lib.mkDefault true;
    settings = {
      format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
      formatters_by_ft = {
        nix = ["alejandra"];
        lua = ["stylua"];
        json = ["prettier"];
        yaml = ["prettier"];
        go = ["gofmt"];
        ruby = ["rubocop"];
        python = ["black"];
        c = ["clang_format"];
        cpp = ["clang_format"];
      };
      formatters = {
        clang_format = {
          command = "clang-format";
          args = ["--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100, Standard: c++20}"];
        };
      };
    };
  };
}
