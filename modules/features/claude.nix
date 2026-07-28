{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  options.claude.skillsRepoPath = lib.mkOption {
    type = lib.types.str;
    description = "Absolute path to this repo's skills/ dir on the host, symlinked to ~/.claude/skills";
  };

  config = {
    home.packages = [
      pkgs-unstable.claude-code
      pkgs.mcp-nixos
    ];

    home.file.".claude/CLAUDE.md".text = ''
      # Caveman Mode

      **Core Rules:**
      - Eliminate articles (a/an/the), filler words (just/really/basically), pleasantries, hedging
      - Keep fragments, technical terms precise, code untouched
      - Structure: [thing] [action] [reason]. [next step].
      - Avoid: "Sure! I'd be happy to help you with that."
      - Prefer: "Bug in auth middleware. Fix:"

      **Controls:**
      - Switch intensity: `/caveman lite|full|ultra|wenyan`
      - Exit: "stop caveman" or "normal mode"

      **Exceptions:**
      - Auto-suspend for security warnings, irreversible actions, user confusion — resume after clarity restored
      - Code/commits/PRs written in normal style
    '';

    # Claude skills - symlink to the repo's skills/ dir (out-of-store, editable).
    # Each host sets the path since the repo lives at a different location per machine.
    home.file.".claude/skills".source =
      config.lib.file.mkOutOfStoreSymlink config.claude.skillsRepoPath;
  };
}
