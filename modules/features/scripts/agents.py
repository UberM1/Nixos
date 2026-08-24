#!/usr/bin/env python3
"""Pick a running coding agent across every kitty instance and jump to it.

Discovers kitty control sockets in the temp dir, asks each one for its window
tree, and keeps the windows whose foreground process is a known agent CLI.
"""

import glob
import json
import os
import stat
import subprocess
import sys
import tempfile

AGENTS = {
    "claude": "claude",
    "codex": "codex",
    "gemini": "gemini",
    "opencode": "opencode",
    "cursor-agent": "cursor",
    "aider": "aider",
    "goose": "goose",
    "amp": "amp",
    "crush": "crush",
    "qwen": "qwen",
}

SELF = os.path.abspath(__file__)
SEP = "\x1f"


def sockets():
    found = []
    listen_on = os.environ.get("KITTY_LISTEN_ON", "")
    if listen_on.startswith("unix:"):
        found.append(listen_on[len("unix:"):])
    for d in {tempfile.gettempdir(), "/tmp"}:
        for path in glob.glob(os.path.join(d, "kitty-*")):
            try:
                if stat.S_ISSOCK(os.stat(path).st_mode):
                    found.append(path)
            except OSError:
                continue
    return sorted(set(found))


def kitty(sock, *args):
    return subprocess.run(
        ["kitty", "@", "--to", f"unix:{sock}", *args],
        capture_output=True,
        text=True,
        timeout=5,
    )


INTERPRETERS = {
    "sh", "bash", "zsh", "dash", "fish", "env",
    "node", "nodejs", "deno", "bun", "python", "ruby", "perl",
}


def command_name(args):
    """Basename of the real program behind a command line.

    Wrapper scripts show up as `/bin/sh /path/to/agent` and node CLIs as
    `node /path/to/agent`, so step over the interpreter and its flags.
    """
    for token in args.split():
        base = os.path.basename(token)
        if base.startswith("-"):
            continue
        if base.rstrip("0123456789.") in INTERPRETERS:
            continue
        return base
    return ""


def process_tree():
    """Map every pid to its children, plus each pid's argv[0] basename."""
    result = subprocess.run(
        ["ps", "-eo", "pid=,ppid=,args="], capture_output=True, text=True
    )
    children = {}
    names = {}
    for line in result.stdout.splitlines():
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        try:
            pid, ppid = int(parts[0]), int(parts[1])
        except ValueError:
            continue
        children.setdefault(ppid, []).append(pid)
        names[pid] = command_name(parts[2])
    return children, names


def agent_of(window, children, names):
    """Find an agent anywhere under the pane, not just in its foreground group.

    A suspended, backgrounded or nested agent never shows up in
    foreground_processes, so walk the whole subtree rooted at the pane.
    """
    root = window.get("pid")
    if root is None:
        return None
    stack, seen = [root], set()
    while stack:
        pid = stack.pop()
        if pid in seen:
            continue
        seen.add(pid)
        agent = AGENTS.get(names.get(pid, ""))
        if agent is not None:
            return agent
        stack.extend(children.get(pid, []))
    return None


IDLE_GLYPHS = set("✻✽✳✶✢·*")


def state_of(title):
    """Read the agent's own status glyph out of the terminal title.

    A spinning braille frame means it is generating; the static glyphs mean it
    is sitting at its prompt waiting for you. No glyph at all means the agent
    is not the thing drawing the title.
    """
    if not title:
        return "unknown"
    head = title[0]
    if 0x2800 <= ord(head) <= 0x28FF:
        return "working"
    if head in IDLE_GLYPHS:
        return "idle"
    return "unknown"


def strip_glyph(title):
    if state_of(title) == "unknown":
        return title.strip()
    return title[1:].strip()


def shorten(path):
    home = os.path.expanduser("~")
    return "~" + path[len(home):] if path.startswith(home) else path


def collect():
    rows = []
    children, names = process_tree()
    for sock in sockets():
        result = kitty(sock, "ls")
        if result.returncode != 0:
            continue
        try:
            tree = json.loads(result.stdout)
        except json.JSONDecodeError:
            continue
        for os_window in tree:
            for tab in os_window.get("tabs", []):
                for window in tab.get("windows", []):
                    agent = agent_of(window, children, names)
                    if agent is None:
                        continue
                    # The tab title follows whichever window is active in that
                    # tab, so it may describe a neighbouring nvim instead.
                    title = window.get("title") or ""
                    if state_of(title) == "unknown":
                        title = tab.get("title") or title
                    rows.append(
                        {
                            "socket": sock,
                            "id": window["id"],
                            "agent": agent,
                            "cwd": shorten(window.get("cwd") or ""),
                            "title": strip_glyph(title),
                            "state": state_of(title),
                        }
                    )
    return rows


STATE_MARK = {"working": "●", "idle": "○", "unknown": "·"}
STATE_ORDER = {"working": 0, "idle": 1, "unknown": 2}


def render(row):
    mark = STATE_MARK[row["state"]]
    label = f"{mark} {row['agent']:<9} {row['cwd']:<34} {row['title']}"
    return f"{row['socket']}{SEP}{row['id']}{SEP}{label}"


# Launched straight from a kitty keybinding there is no shell, so
# FZF_DEFAULT_OPTS never reaches us. Carry the navigation keys ourselves.
VIM_KEYS = [
    "--cycle",
    "--bind=ctrl-d:half-page-down,ctrl-u:half-page-up",
    "--bind=alt-g:first,alt-G:last",
    "--bind=alt-j:preview-down,alt-k:preview-up",
    "--bind=alt-p:toggle-preview",
    "--bind=ctrl-alt-u:clear-query",
]


def preview(sock, window_id):
    result = kitty(sock, "get-text", "--match", f"id:{window_id}", "--extent", "screen")
    sys.stdout.write(result.stdout if result.returncode == 0 else result.stderr)


def main(argv):
    if len(argv) == 4 and argv[1] == "--preview":
        preview(argv[2], argv[3])
        return 0

    rows = collect()
    if not rows:
        print("No coding agents running in any kitty window.", file=sys.stderr)
        return 1

    if "--list" in argv:
        for row in rows:
            print(render(row).replace(SEP, "  "))
        return 0

    rows.sort(key=lambda r: (STATE_ORDER[r["state"]], r["cwd"]))
    chosen = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--delimiter", SEP,
            "--with-nth", "3",
            "--height", "100%",
            "--layout=reverse",
            "--border",
            "--header",
            "^j/^k move  ^d/^u page  M-j/M-k scroll preview  |  ● working  ○ waiting  · backgrounded",
            "--preview", f"python3 {SELF} --preview {{1}} {{2}}",
            "--preview-window", "down:70%:wrap",
            *VIM_KEYS,
        ],
        input="\n".join(render(row) for row in rows),
        capture_output=True,
        text=True,
    )
    if chosen.returncode != 0 or not chosen.stdout.strip():
        return 0

    sock, window_id, _ = chosen.stdout.strip().split(SEP, 2)
    kitty(sock, "focus-window", "--match", f"id:{window_id}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
