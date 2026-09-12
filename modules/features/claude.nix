{
  inputs,
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

      # Same mechanism: a --plugin-dir on the wrapper, so the skills are on-demand
      # (invoked by name) instead of always-on context, and they follow the flake
      # lock rather than a manual clone. Not programs.claude-code.marketplaces:
      # that option would take over ~/.claude/settings.json, which stays mutable.
      plugins = [inputs.mattpocock-skills];
    };

    # Not programs.claude-code.skills: that copies into the store, read-only.
    home.file.".claude/skills".source =
      config.lib.file.mkOutOfStoreSymlink config.claude.skillsRepoPath;
  };
}
