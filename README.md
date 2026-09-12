# Nixos

Nix flake managing two personal machines — a MacBook and a NixOS desktop — from a shared,
feature-based module tree. Features are composed into hosts by explicit `imports`; there is
no auto-discovery. Theming is centralized through [stylix](https://github.com/danth/stylix).

Nothing here is applied automatically. Every change lands through an explicit rebuild on
the machine:

```sh
sudo darwin-rebuild switch --flake .#macbook-air   # MacBook
sudo nixos-rebuild switch --flake .#ubr            # NixOS desktop
```

## Working on the repo

```sh
nix fmt .            # format (alejandra) — the path argument is required
nix flake check      # format + statix + deadnix + evaluate every host
```

[CLAUDE.md](./CLAUDE.md) is the contributor guide and the single source of truth for the
host table, module layout, conventions, theming rules and workflow. Read it before adding
a module.
