{
  inputs,
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: let
  # Everything the bar shows comes from the JSON Claude Code pipes in on stdin —
  # including .context_window.used_percentage, so no ccstatusline/npx needed.
  statusLine = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [pkgs.git pkgs.jq];
    text = ''
      # printf %f parses "17.34", not "17,34", whatever the ambient locale is.
      export LC_ALL=C

      input=$(cat)
      cwd=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
      pct=$(jq -r '.context_window.used_percentage // ""' <<<"$input")
      [ -d "$cwd" ] || cwd=$PWD

      if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel)
        prefix=$(git -C "$cwd" --no-optional-locks rev-parse --show-prefix)
        label="$(basename "$root")''${prefix:+/''${prefix%/}}"
        branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

        # One porcelain call instead of three diffs: X is the index column,
        # Y the worktree column, "??" untracked.
        read -r staged unstaged untracked < <(
          git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null |
            awk '/^\?\?/ { a++; next }
                 { if (substr($0, 1, 1) != " ") s++; if (substr($0, 2, 1) != " ") u++ }
                 END { printf "%d %d %d\n", s + 0, u + 0, a + 0 }'
        )

        out=$(printf '\033[1;36m%s\033[0m | \033[1;32m%s\033[0m | S: \033[1;33m%s\033[0m | U: \033[1;33m%s\033[0m | A: \033[1;33m%s\033[0m' \
          "$label" "''${branch:-detached}" "$staged" "$unstaged" "$untracked")
      else
        out=$(printf '\033[1;36m%s\033[0m' "''${cwd/#$HOME/\~}")
      fi

      # Colors are ANSI indices on purpose: the terminal palette is stylix-themed,
      # so the bar follows the scheme without hardcoding any hex.
      if [ -n "$pct" ]; then
        rounded=$(printf '%.0f' "$pct")
        if [ "$rounded" -lt 50 ]; then
          color=32
        elif [ "$rounded" -lt 80 ]; then
          color=33
        else
          color=31
        fi
        out=$(printf '%s | \033[1;%sm%.1f%%\033[0m' "$out" "$color" "$pct")
      fi

      printf '%s' "$out"
    '';
  };

  # settings.json is deliberately mutable (Claude writes model/tui/enabledPlugins
  # into it), so patch in just the keys we own instead of using
  # programs.claude-code.settings, which would replace the file with a read-only
  # store symlink.
  patchSettings = pkgs.writeShellApplication {
    name = "claude-patch-settings";
    runtimeInputs = [pkgs.jq];
    text = ''
      settings=''${1:?usage: claude-patch-settings <settings.json>}
      mkdir -p "$(dirname "$settings")"
      [ -s "$settings" ] || printf '{}\n' >"$settings"

      tmp=$(mktemp "$settings.XXXXXX")
      # remoteControlAtStartup: sessions start with Remote Control off; /remote-control
      # still turns it on for the session that asks for it.
      if ! jq '.statusLine = {type: "command", command: "bash ~/.claude/statusline.sh"}
              | .remoteControlAtStartup = false' \
        "$settings" >"$tmp"; then
        echo "claude: $settings is not valid JSON, leaving it alone" >&2
        rm -f "$tmp"
        exit 0
      fi
      mv "$tmp" "$settings"
    '';
  };
in {
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

    # Fixed path so the command in settings.json survives every rebuild.
    home.file.".claude/statusline.sh".source = lib.getExe statusLine;

    home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe patchSettings} "${config.home.homeDirectory}/.claude/settings.json"
    '';
  };
}
