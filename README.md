# Nixos

Nix flake managing two personal machines with a shared, feature-based module tree.

## Hosts

| Host | Platform | Role | Apply |
|---|---|---|---|
| `macbook-air` | aarch64-darwin | laptop | `sudo darwin-rebuild switch --flake .#macbook-air` |
| `ubr` | x86_64-linux | desktop (Hyprland) | `sudo nixos-rebuild switch --flake .#ubr` |

Nothing here is applied automatically — every change lands through an explicit rebuild on
the machine.

## Layout

```
flake.nix                  inputs, formatter, checks, host outputs
modules/
  hosts/<name>/            per-host entry points and host-only modules
  features/                home-manager modules shared by both desktops
  features-nixos/          NixOS desktop only (home/ + system/)
  features-darwin/         macOS only (home/ + system/)
skills/                    Claude skills, symlinked into ~/.claude/skills
```

Features are composed into hosts by explicit `imports` — there is no auto-discovery.
Theming is centralized through [stylix](https://github.com/danth/stylix).

## Machine-local configuration

Anything specific to a particular employer or network — cluster names, VPN profiles,
internal hostnames — is kept out of this repo. `programs.zsh` sources
`~/.secrets/work-env.zsh` when it exists; create it with mode `0600` and it stays out of
both the store and git.

## Working on the repo

```sh
nix fmt              # format (alejandra)
nix flake check      # format + statix + deadnix + evaluate every host
```

See [CLAUDE.md](./CLAUDE.md) for the full contributor guide (module conventions, theming
rules, dendritic structure).
