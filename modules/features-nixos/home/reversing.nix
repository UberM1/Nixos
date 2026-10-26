{
  pkgs,
  pkgs-unstable,
  ...
}: let
  # 26.05 ships 12.0.4, which rea rejects outright: it gates on
  # major == 12 && minor >= 1. Unstable is at 12.1.2, which it accepts as a
  # "compatible 12.1.x release" against its verified 12.1.4 build.
  inherit (pkgs-unstable) ghidra;

  # rea probes the install root for Ghidra/application.properties,
  # support/analyzeHeadless and the native decompiler, so it wants the
  # application directory, not the package root.
  ghidraHome = "${ghidra}/lib/ghidra";

  # Not packaged in nixpkgs, and vendoring its dependency tree is more upkeep
  # than this is worth while the project is exploratory. Pinning the version
  # keeps the npx fetch reproducible enough: an exact version resolves to one
  # immutable tarball.
  reaVersion = "6.8.0";

  rea = pkgs.writeShellApplication {
    name = "rea";
    runtimeInputs = [
      # rea wants 22.23.4+, 24.22.1+ or 26.12.1+ and no nixpkgs node meets any of
      # those: 26.05 has 24.19.0, unstable 24.20.0, and even nodejs_26 is 26.8.2.
      # They are security-patch floors, so `rea doctor` reports node unhealthy and
      # everything still runs. Revisit when nixpkgs catches up.
      pkgs.nodejs_24
      pkgs.jdk
      pkgs.procps # rea checks process ownership before spawning Ghidra
    ];
    text = ''
      export GHIDRA_INSTALL_DIR=${ghidraHome}
      exec npx -y rea-agents@${reaVersion} "$@"
    '';
  };
in {
  home.packages = [
    ghidra
    rea
  ];

  home.sessionVariables.GHIDRA_INSTALL_DIR = ghidraHome;

  # Merges with the servers declared in features/claude.nix. Kept here because
  # the server is useless without the Ghidra above, and that is NixOS-only.
  programs.mcp.servers.rea = {
    command = "${rea}/bin/rea";
    args = ["mcp"];
    env = {
      # rea exposes ~126 tools across every target family. Only these two
      # matter for native binaries, and the full set crowds the context.
      REA_MCP_TOOL_FAMILIES = "session,native";
      REA_MCP_INPUT_SCHEMA_PROFILE = "compact";
    };
  };
}
