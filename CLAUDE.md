# Repo guide for AI agents

Nix flake (flake-parts) managing two personal machines: a MacBook and a NixOS desktop.
The repo lives at `/Users/matiasuberti/Nixos` on the mac and `/home/ubr/nixos_conf` on
the NixOS desktop — some modules hardcode these paths on purpose (e.g. the
`claude.skillsRepoPath` option).

The `bastion` server moved out to [UberM1/nixos-bastion](https://github.com/UberM1/nixos-bastion);
nothing here describes that machine any more.

## Hosts

| Host | Output | Platform | Role | Applied by |
|---|---|---|---|---|
| `macbook-air` | `darwinConfigurations.macbook-air` | aarch64-darwin | laptop | `sudo darwin-rebuild switch --flake .#macbook-air` |
| `ubr` | `nixosConfigurations.ubr` | x86_64-linux | desktop (Hyprland) | `sudo nixos-rebuild switch --flake .#ubr` |

## Inputs

Both hosts track `nixos-26.05` / `nixpkgs-26.05-darwin`, with `nixpkgs-unstable` available
as `pkgs-unstable` via `extraSpecialArgs` where a newer package is needed.

## Module layout (dendritic-inspired)

The repo aims at the [dendritic pattern](https://github.com/mightyiam/dendritic): small
single-purpose feature modules composed per host, instead of monolithic host configs.
Current state is a hybrid — only `modules/hosts/*/default.nix` are flake-parts modules
(each defines its own flake output); feature files are plain home-manager/NixOS modules
imported by explicit relative path. Keep new code in that shape: one feature per file,
wired into hosts via `imports`, never by growing `configuration.nix`/`home.nix` inline.

```
flake.nix                inputs, formatter, checks, host outputs
modules/
  hosts/<name>/          entry point (default.nix defines the flake output) + host-only modules
  features/              home-manager modules shared by BOTH desktops (mac + ubr)
  features-nixos/        home/ and system/ modules for NixOS desktop only
  features-darwin/       home/ and system/ modules for macOS only
skills/                  Claude skills, symlinked to ~/.claude/skills on both desktops
```

Conventions:
- Everything is imported by explicit relative path from each host's `configuration.nix` /
  `home.nix` — there is no auto-discovery. A new module does nothing until a host imports it.
- Same-named files in `features/` and `features-nixos/home/` (e.g. `kitty.nix`,
  `stylix.nix`, `apps.nix`, `work-pkgs.nix`) are intentional: the shared base and a
  platform-specific extension, both imported by ubr. Don't merge or dedupe them.
- `modules/features/claude.nix` wires Claude Code: MCP servers, plugins, and an
  out-of-store symlink from `skills/` to `~/.claude/skills`. Because that symlink escapes
  the store, adding or editing a skill is live immediately; changing `claude.nix` itself
  still needs a rebuild.

## Theming: stylix first

Stylix runs with `autoEnable = true` (`modules/features/stylix.nix`), so most apps pick up
the base16 scheme, fonts and cursor automatically. When adding an app:

1. Check whether stylix has a target for it (`stylix.targets.<app>`); if it needs explicit
   enabling, add it to the shared `features/stylix.nix` (or `features-nixos/home/stylix.nix`
   if the app is NixOS-only).
2. Only hand-theme when no target exists. Precedent: Qt/KDE (dolphin) is themed manually in
   `features-nixos/home/dolphin.nix` because the stylix Qt target didn't cover it — a
   comment in `features-nixos/home/stylix.nix` records that.
3. Never hardcode colors that stylix already provides — pull from `config.lib.stylix.colors`
   if custom theming is unavoidable.

## Workflow

Nothing here is applied automatically — every change lands through an explicit rebuild on
the machine, using the command in the Hosts table.

1. Format: `nix fmt .` (alejandra). Pass the path: bare `nix fmt` reads stdin, fails, and
   still exits 0.
2. Verify before handing work back. `nix flake check` runs format, statix and deadnix and
   evaluates every host. Two faster loops while iterating: build one check
   (`nix build .#checks.x86_64-linux.statix`), or evaluate just the option you touched
   (`nix eval .#nixosConfigurations.ubr.config.<path>`), which proves the wiring without a
   rebuild.
3. Commit messages: imperative one-liners explaining why, matching `git log` style.
4. Ask before pushing to main.
