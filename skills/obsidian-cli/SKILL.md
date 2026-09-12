---
name: obsidian-cli
description: "Drive a running Obsidian desktop app from the shell: read, create, search and link notes through Obsidian's own index, or reload and debug a plugin or theme. Use for vault operations that beat grep, and for the plugin develop/test cycle."
---

# Obsidian CLI

The binary is `obsidian-cli`. `obsidian` is the Electron GUI launcher and `obs` is OBS
Studio; both ignore these arguments. Upstream's own help text prints `Usage: obsidian
<command>`, which is the name upstream expects, not the name nixpkgs installs.

Commands reach the **running** desktop app over IPC. With Obsidian closed they fail, and
the fallback is direct Read/Write/Grep on the vault directory.

## Command reference

`obsidian-cli help` lists every command and its parameters, and it is generated from the
installed binary, so it never goes stale. Read it before guessing at a command name.

Web docs, for concepts rather than syntax: https://help.obsidian.md/cli

## Calling convention

What `help` does not spell out:

- **Parameters** take a value with `=`; **flags** are bare words.
  ```bash
  obsidian-cli create name="My Note" content="Hello world" silent overwrite
  ```
- Quote any value containing spaces. Use `\n` and `\t` inside `content=` for multiline text.
- **File targeting**: `file=<name>` resolves like a wikilink (no path, no extension);
  `path=<path>` is exact from the vault root. With neither, the command hits the active file.
- **Vault targeting**: commands go to the most recently focused vault. To pin one, put
  `vault=<name>` first, before the command:
  ```bash
  obsidian-cli vault="My Vault" search query="test"
  ```
- Useful modifiers on most commands: `--copy` sends output to the clipboard, `silent`
  stops the file opening in the GUI, `total` turns a list command into a count.

## Plugin develop/test cycle

After changing plugin or theme code, run the loop until `dev:errors` comes back clean:

1. `obsidian-cli plugin:reload id=my-plugin` — pick up the new code
2. `obsidian-cli dev:errors` — on any error, fix and return to step 1
3. `obsidian-cli dev:screenshot path=shot.png` or `obsidian-cli dev:dom selector=".workspace-leaf" text` — confirm the change visually
4. `obsidian-cli dev:console level=error` — catch warnings the error pane misses

A reload that reports no errors proves the plugin loaded, not that it works. Step 3 is
what closes that gap, so run it on every cycle rather than only when something looks wrong.
