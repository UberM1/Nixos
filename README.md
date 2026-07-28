# Nixos

Nix flake managing three machines with a shared, feature-based module tree.

## Hosts

| Host | Platform | Role | Apply |
|---|---|---|---|
| `macbook-air` | aarch64-darwin | laptop | `sudo darwin-rebuild switch --flake .#macbook-air` |
| `ubr` | x86_64-linux | desktop (Hyprland) | `sudo nixos-rebuild switch --flake .#ubr` |
| `bastion` | x86_64-linux | server (media + observability) | auto — see below |

**Bastion deploys itself.** [comin](https://github.com/nlewo/comin) watches `main` and
applies any commit touching the bastion closure to the live server. A push to `main` is a
production deploy — never run `nixos-rebuild` against it by hand.

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

## Working on the repo

```sh
nix fmt              # format (alejandra)
nix flake check      # format + statix + deadnix + evaluate every host
```

See [CLAUDE.md](./CLAUDE.md) for the full contributor guide (pinning rules, dendritic
structure, theming conventions).
