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
    # Declared here, not in programs.claude-code.mcpServers: only this path
    # applies wrapEnvFilesCommand, which keeps env-file secrets out of the store.
    programs.mcp = {
      enable = true;

      servers = {
        nixos.command = lib.getExe pkgs.mcp-nixos;

        # OAuth in-band: authenticate with /mcp inside a session.
        metabase.url = "https://metabase.monitorbit.xyz/api/metabase-mcp";

        # Behind netbird; the VPN must be up for this to resolve.
        grafana = {
          command = lib.getExe pkgs.mcp-grafana;
          args = ["-t" "stdio"];
          env = {
            GRAFANA_URL = "https://grafana.monitorbit.xyz";
            # install -Dm600 /dev/stdin ~/.secrets/grafana-mcp-token <<< '<token>'
            GRAFANA_API_KEY.file = "${config.home.homeDirectory}/.secrets/grafana-mcp-token";
          };
        };
      };
    };

    programs.claude-code = {
      enable = true;
      package = pkgs-unstable.claude-code;

      # Ships programs.mcp.servers as a --plugin-dir, leaving ~/.claude.json mutable.
      enableMcpIntegration = true;

      context = ''
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
    };

    # Not programs.claude-code.skills: that copies into the store, read-only.
    home.file.".claude/skills".source =
      config.lib.file.mkOutOfStoreSymlink config.claude.skillsRepoPath;
  };
}
