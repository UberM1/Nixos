# Dendritic NixOS/Darwin Configuration

## Architecture

```
modules/
├── features/              # Cross-platform home-manager modules
├── features-nixos/
│   ├── system/            # NixOS system modules
│   └── home/              # NixOS home-manager modules
├── features-darwin/
│   ├── system/            # Darwin system modules
│   └── home/              # Darwin home-manager modules
└── hosts/
    ├── ubr/               # NixOS workstation
    └── macbook-air/       # Darwin laptop
```

## Rules

1. **No mkIf platform checks in features/**. Cross-platform modules must work on both systems without conditionals.

2. **Platform-specific code goes in platform directories**:
   - Linux-only settings → `features-nixos/home/` or `features-nixos/system/`
   - Darwin-only settings → `features-darwin/home/` or `features-darwin/system/`

3. **Hosts import explicitly**. Each host imports:
   - Base features from `features/`
   - Platform extensions from `features-{nixos,darwin}/`

## Adding Features

### Cross-platform feature (features/)

```nix
# modules/features/example.nix
{pkgs, ...}: {
  programs.example = {
    enable = true;
    # Settings that work on both platforms
  };
}
```

Then import in both hosts' home.nix:
```nix
imports = [
  ../../features/example.nix
];
```

### Platform-specific extension

If the feature needs platform-specific settings, create an extension:

```nix
# modules/features-nixos/home/example.nix
{...}: {
  programs.example = {
    # Linux-only settings
    extraOption = "linux-value";
  };
}
```

Import in the NixOS host only:
```nix
imports = [
  ../../features/example.nix
  ../../features-nixos/home/example.nix
];
```

### System-level feature

```nix
# modules/features-nixos/system/example.nix
{...}: {
  services.example.enable = true;
}
```

Import in host's configuration.nix:
```nix
imports = [
  ../../features-nixos/system/example.nix
];
```

## Host Structure

Each host has:
- `default.nix` - Flake-parts registration (nixosConfigurations/darwinConfigurations)
- `configuration.nix` - System config, imports system features
- `home.nix` - Home-manager config, imports home features
- `hardware-configuration.nix` - (NixOS only)

## Inputs

- `nixpkgs` - NixOS stable
- `nixpkgs-darwin` - Darwin stable (used by nix-darwin)
- `nixpkgs-unstable` - Unstable channel
- `nix-darwin` - Darwin system management
- `home-manager` - User environment
- `stylix` - Theming (cross-platform)
- `nixvim` - Neovim config (cross-platform)

## Commands

```bash
# NixOS
nixos-rebuild switch --flake .#ubr

# Darwin
darwin-rebuild switch --flake .#macbook-air

# Evaluate
nix eval .#nixosConfigurations.ubr.config.home-manager.users.ubr.programs.kitty.enable
nix eval .#darwinConfigurations.macbook-air.config.home-manager.users.matiasuberti.programs.kitty.enable
```
