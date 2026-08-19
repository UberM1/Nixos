{pkgs, ...}: {
  # vimtex shells out to latexmk and zathura by name, so they must be on PATH.
  # scheme-medium turns out not to cover much beyond the basics, so the packages
  # actually used by documents here are listed explicitly. xcharter additionally
  # needs fontaxes, which nothing pulls in for it: without both, a document
  # asking for XCharter dies on a missing .sty or silently falls back to charter.
  home.packages = [
    (pkgs.texlive.withPackages (ps:
      with ps; [
        scheme-medium
        xcharter
        fontaxes
        enumitem
        titlesec
        fancyhdr
        microtype
        xcolor
        geometry
        hyperref
        babel-english
        charter
        psnfss
        wrapfig
        cancel
      ]))
    pkgs.zathura
  ];

  programs.nixvim = {
    # Nixvim has no vimtex module, so it goes in as a raw plugin.
    extraPlugins = [pkgs.vimPlugins.vimtex];

    # vimtex reads its configuration from globals at load time, not via setup().
    globals = {
      vimtex_view_method = "zathura";
      vimtex_compiler_method = "latexmk";
      vimtex_quickfix_open_on_warning = 0;

      # Default maps sit under <localleader>l, and maplocalleader is <space>
      # here, which collides with the <leader>l window move: <space>l would wait
      # out timeoutlen before deciding. Own maps under <leader>t instead.
      vimtex_mappings_enabled = 0;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>tc";
        action = ":VimtexCompile<CR>";
        options.desc = "LaTeX: toggle compile-on-save";
      }
      {
        mode = "n";
        key = "<leader>tv";
        action = ":VimtexView<CR>";
        options.desc = "LaTeX: jump viewer to cursor";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action = ":VimtexStop<CR>";
        options.desc = "LaTeX: stop compiling";
      }
      {
        mode = "n";
        key = "<leader>te";
        action = ":VimtexErrors<CR>";
        options.desc = "LaTeX: show errors";
      }
    ];
  };
}
