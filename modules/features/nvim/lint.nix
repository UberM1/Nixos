{
  lib,
  pkgs,
  ...
}: {
  # nvim-lint shells out to these by name, so they must be on PATH.
  home.packages = [pkgs.statix pkgs.deadnix];

  programs.nixvim = {
    plugins.lint = {
      enable = lib.mkDefault true;
      lintersByFt.nix = ["statix" "deadnix"];
    };

    # nvim-lint doesn't lint on its own; trigger it on the usual events.
    # require() is deferred to fire time so plugin load order doesn't matter.
    autoCmd = [
      {
        event = ["BufWritePost" "BufReadPost" "InsertLeave"];
        callback.__raw = ''
          function()
            require("lint").try_lint()
          end
        '';
      }
    ];
  };
}
