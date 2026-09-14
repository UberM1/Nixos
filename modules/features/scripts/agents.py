#!/usr/bin/env python3
"""Jump to a running coding agent, or find and resume a past Claude session.

One list, three sections: agents running in any kitty window, contexts saved
into a named group tree, and recent Claude sessions that were never saved.

Navigation is vim-style and deliberately uses no control chords, so kitty's own
ctrl+hjkl window bindings never reach in and steal a keystroke.

The transcript format under ~/.claude/projects is internal to Claude Code and
changes between releases, so every field read out of it degrades: ai-title falls
back to the first user prompt, which falls back to the session id. The running
agents section parses no transcripts at all and cannot break that way.
"""

import curses
import glob
import json
import os
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import threading
import time

HOME = os.path.expanduser("~")
PROJECTS = os.path.join(HOME, ".claude", "projects")
STORE = os.environ.get("CLAUDE_CONTEXTS_DIR") or os.path.join(
    HOME, ".local", "share", "claude-contexts"
)
INDEX_PATH = os.path.join(STORE, "index.json")
TRANSCRIPTS = os.path.join(STORE, "transcripts")

RECENT_LIMIT = 25
GREP_MIN_QUERY = 3

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


# ── kitty ────────────────────────────────────────────────────────────────────

def sockets():
    found = []
    listen_on = os.environ.get("KITTY_LISTEN_ON", "")
    if listen_on.startswith("unix:"):
        found.append(listen_on[len("unix:"):])
    for d in {tempfile.gettempdir(), "/tmp"}:
        for path in glob.glob(os.path.join(d, "kitty-*")) + glob.glob(os.path.join(d, "kitty")):
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
        timeout=10,
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
    """Map every pid to its children, plus each pid's name and full argv."""
    result = subprocess.run(
        ["ps", "-eo", "pid=,ppid=,args="], capture_output=True, text=True
    )
    children, names, argv = {}, {}, {}
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
        argv[pid] = parts[2]
    return children, names, argv


def agent_of(window, children, names):
    """Find an agent anywhere under the pane, not just in its foreground group.

    A suspended, backgrounded or nested agent never shows up in
    foreground_processes, so walk the whole subtree rooted at the pane.
    """
    root = window.get("pid")
    if root is None:
        return None, None
    stack, seen = [root], set()
    while stack:
        pid = stack.pop()
        if pid in seen:
            continue
        seen.add(pid)
        agent = AGENTS.get(names.get(pid, ""))
        if agent is not None:
            return agent, pid
        stack.extend(children.get(pid, []))
    return None, None


IDLE_GLYPHS = set("✻✽✳✶✢·*")

# Braille frames, half circles, arcs and quadrants: the spinner alphabets agent
# CLIs cycle through while generating. An unrecognised frame reads as "not an
# agent title" and poisons everything downstream, so cover the whole family.
SPINNER_RANGES = (
    (0x2800, 0x28FF),
    (0x25D0, 0x25D3),
    (0x25DC, 0x25DF),
    (0x25F4, 0x25F7),
)


def state_of(title):
    """Read the agent's own status glyph out of the terminal title.

    A spinner frame means it is generating; the static glyphs mean it is
    sitting at its prompt waiting for you. No glyph at all means the agent is
    not the thing drawing the title.
    """
    if not title:
        return "unknown"
    head = ord(title[0])
    if any(low <= head <= high for low, high in SPINNER_RANGES):
        return "working"
    if title[0] in IDLE_GLYPHS:
        return "idle"
    return "unknown"


def strip_glyph(title):
    if state_of(title) == "unknown":
        return title.strip()
    return title[1:].strip()


def shorten(path):
    return "~" + path[len(HOME):] if path.startswith(HOME) else path


def collect_agents():
    rows = []
    children, names, argv = process_tree()
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
                found = []
                for window in tab.get("windows", []):
                    agent, pid = agent_of(window, children, names)
                    if agent is not None:
                        found.append((window, agent, pid))
                for window, agent, pid in found:
                    # The tab title follows whichever window is active in that
                    # tab, so it may describe a neighbouring nvim instead. With
                    # two agents in one tab it would label both the same, so
                    # only borrow it when this tab holds a single agent.
                    title = window.get("title") or ""
                    if state_of(title) == "unknown" and len(found) == 1:
                        title = tab.get("title") or title
                    rows.append(
                        {
                            "socket": sock,
                            "window": window["id"],
                            "pid": pid,
                            "argv": argv.get(pid, ""),
                            "agent": agent,
                            "cwd": window.get("cwd") or "",
                            "title": strip_glyph(title),
                            "state": state_of(title),
                        }
                    )
    return rows


# ── claude transcripts ───────────────────────────────────────────────────────

def slugify(path):
    """Claude's project directory name for a working directory."""
    return re.sub(r"[/_.]", "-", path)


def transcript_paths():
    # One level only: subagent transcripts live a directory deeper and are not
    # resumable sessions.
    return glob.glob(os.path.join(PROJECTS, "*", "*.jsonl"))


def read_chunk(path, size, tail=False):
    try:
        with open(path, "rb") as fh:
            if tail:
                fh.seek(0, os.SEEK_END)
                end = fh.tell()
                fh.seek(max(0, end - size))
                data = fh.read()
                if end > size:
                    # The seek lands mid-line; that fragment is not valid JSON.
                    data = data.partition(b"\n")[2]
            else:
                data = fh.read(size)
    except OSError:
        return []
    return data.decode("utf-8", "replace").splitlines()


def json_lines(lines):
    for line in lines:
        try:
            entry = json.loads(line)
        except (ValueError, TypeError):
            continue
        if isinstance(entry, dict):
            yield entry


def user_text(entry):
    """The prompt you typed, or empty for anything else in the transcript."""
    if entry.get("type") != "user":
        return ""
    content = (entry.get("message") or {}).get("content")
    if isinstance(content, list):
        content = "".join(
            part.get("text", "")
            for part in content
            if isinstance(part, dict) and part.get("type") == "text"
        )
    if not isinstance(content, str):
        return ""
    content = content.split("<system-reminder>")[0].strip()
    if not content:
        return ""
    noise = ("<command-name>", "<local-command", "Caveat:", "[Request interrupted")
    if content.startswith(noise):
        return ""
    return content


def squash(text, limit=90):
    text = " ".join(text.split())
    return text[: limit - 1] + "…" if len(text) > limit else text


def session_meta(path):
    """Label a transcript without trusting any single internal field."""
    sid = os.path.basename(path)[: -len(".jsonl")]
    title = ""
    for entry in json_lines(read_chunk(path, 64 * 1024, tail=True)):
        if entry.get("type") == "ai-title" and entry.get("aiTitle"):
            title = entry["aiTitle"]

    cwd = ""
    if not title or not cwd:
        for entry in json_lines(read_chunk(path, 96 * 1024)):
            if not cwd and entry.get("cwd"):
                cwd = entry["cwd"]
            if not title:
                text = user_text(entry)
                if text:
                    title = squash(text, 70)
            if title and cwd:
                break

    if not cwd:
        cwd = _sibling_cwd(path)

    try:
        mtime = os.path.getmtime(path)
    except OSError:
        mtime = 0.0
    return {
        "id": sid,
        "path": path,
        "cwd": cwd,
        "title": title or sid[:8],
        "mtime": mtime,
    }


def _sibling_cwd(path):
    """Borrow the working directory from another session in the same project.

    The directory name is a lossy slug of the path (both `/` and `_` become
    `-`), so it cannot be decoded back; a neighbour that recorded its cwd can.
    """
    for other in glob.glob(os.path.join(os.path.dirname(path), "*.jsonl")):
        if other == path:
            continue
        for entry in json_lines(read_chunk(other, 32 * 1024)):
            if entry.get("cwd"):
                return entry["cwd"]
    return ""


def session_prompts(path, limit=40):
    """Your side of the conversation, which is what makes a session recognisable."""
    out = []
    try:
        with open(path, errors="ignore") as fh:
            for line in fh:
                try:
                    entry = json.loads(line)
                except (ValueError, TypeError):
                    continue
                if not isinstance(entry, dict):
                    continue
                text = user_text(entry)
                if text:
                    out.append((entry.get("timestamp", "")[:16], text))
    except OSError:
        return []
    return out[:limit]


def grep_sessions(terms, paths):
    """Sessions whose transcript contains every term. Returns path -> hit count."""
    if not terms or not paths:
        return {}
    totals = None
    for term in terms:
        hits = _grep_term(term, paths)
        if totals is None:
            totals = hits
        else:
            totals = {p: n + hits[p] for p, n in totals.items() if p in hits}
        if not totals:
            return {}
    return totals or {}


def _grep_term(term, paths):
    if shutil.which("rg"):
        result = subprocess.run(
            ["rg", "--count", "--fixed-strings", "--ignore-case", "--", term, *paths],
            capture_output=True,
            text=True,
        )
        hits = {}
        for line in result.stdout.splitlines():
            path, _, count = line.rpartition(":")
            try:
                hits[path] = int(count)
            except ValueError:
                continue
        return hits
    needle = term.lower()
    hits = {}
    for path in paths:
        try:
            with open(path, errors="ignore") as fh:
                n = sum(1 for line in fh if needle in line.lower())
        except OSError:
            continue
        if n:
            hits[path] = n
    return hits


def grep_excerpt(path, terms, limit=6):
    """The lines that matched, rendered as prompt text where possible."""
    out = []
    lowered = [t.lower() for t in terms]
    try:
        with open(path, errors="ignore") as fh:
            for line in fh:
                if not all(t in line.lower() for t in lowered):
                    continue
                try:
                    entry = json.loads(line)
                except (ValueError, TypeError):
                    continue
                if not isinstance(entry, dict):
                    continue
                text = user_text(entry) or _assistant_text(entry)
                if text:
                    out.append((entry.get("timestamp", "")[:16], squash(text, 400)))
                if len(out) >= limit:
                    break
    except OSError:
        return []
    return out


def _assistant_text(entry):
    if entry.get("type") != "assistant":
        return ""
    content = (entry.get("message") or {}).get("content")
    if not isinstance(content, list):
        return ""
    return "".join(
        part.get("text", "")
        for part in content
        if isinstance(part, dict) and part.get("type") == "text"
    ).strip()


# ── saved contexts ───────────────────────────────────────────────────────────

def load_index():
    try:
        with open(INDEX_PATH) as fh:
            data = json.load(fh)
    except (OSError, ValueError):
        data = {}
    if not isinstance(data, dict):
        data = {}
    data.setdefault("version", 1)
    data.setdefault("contexts", {})
    data.setdefault("groups", {})
    return data


def save_index(index):
    os.makedirs(STORE, exist_ok=True)
    tmp = INDEX_PATH + ".tmp"
    with open(tmp, "w") as fh:
        json.dump(index, fh, indent=2, ensure_ascii=False)
    os.replace(tmp, INDEX_PATH)


def copy_path(sid):
    return os.path.join(TRANSCRIPTS, sid + ".jsonl")


def pin(index, meta, group):
    ctx = index["contexts"].get(meta["id"], {})
    index["contexts"][meta["id"]] = {
        "name": ctx.get("name") or meta["title"],
        "group": group,
        "cwd": ctx.get("cwd") or meta["cwd"],
        "origin": meta["path"],
        "saved_at": ctx.get("saved_at") or time.strftime("%Y-%m-%dT%H:%M:%S"),
        "synced": 0,
    }
    index["groups"].setdefault(group, {"collapsed": False})
    sync_one(meta["id"], index["contexts"][meta["id"]])
    save_index(index)


def unpin(index, sid):
    index["contexts"].pop(sid, None)
    try:
        os.remove(copy_path(sid))
    except OSError:
        pass
    prune_groups(index)
    save_index(index)


def prune_groups(index):
    """Forget groups nothing lives in any more, so the tree cannot grow stumps."""
    used = set()
    for ctx in index["contexts"].values():
        parts = ctx.get("group", "").split("/")
        for i in range(1, len(parts) + 1):
            used.add("/".join(parts[:i]))
    for path in list(index["groups"]):
        if path not in used:
            del index["groups"][path]


def sync_one(sid, ctx):
    """Refresh our copy when the live transcript has moved on."""
    origin = ctx.get("origin", "")
    if not origin or not os.path.exists(origin):
        return False
    try:
        mtime = os.path.getmtime(origin)
    except OSError:
        return False
    if mtime <= ctx.get("synced", 0):
        return False
    os.makedirs(TRANSCRIPTS, exist_ok=True)
    try:
        shutil.copy2(origin, copy_path(sid))
    except OSError:
        return False
    ctx["synced"] = mtime
    return True


def sync_all(index):
    changed = False
    for sid, ctx in list(index["contexts"].items()):
        changed |= sync_one(sid, ctx)
    if changed:
        save_index(index)


def restore(sid, ctx):
    """Put a saved transcript back where Claude expects it, if cleanup ate it."""
    origin = ctx.get("origin", "")
    mine = copy_path(sid)
    if not origin or os.path.exists(origin) or not os.path.exists(mine):
        return
    try:
        os.makedirs(os.path.dirname(origin), exist_ok=True)
        shutil.copy2(mine, origin)
    except OSError:
        pass


def group_nodes(index):
    """Every group path plus its implied ancestors, sorted for tree rendering."""
    nodes = set(index["groups"])
    nodes.update(ctx["group"] for ctx in index["contexts"].values() if ctx.get("group"))
    for path in list(nodes):
        parts = path.split("/")
        for i in range(1, len(parts)):
            nodes.add("/".join(parts[:i]))
    nodes.discard("")
    return sorted(nodes)


def collapsed(index, path):
    return index["groups"].get(path, {}).get("collapsed", True)


def toggle_group(index, path):
    node = index["groups"].setdefault(path, {})
    node["collapsed"] = not collapsed(index, path)
    save_index(index)


def rename_group(index, old, new):
    for ctx in index["contexts"].values():
        group = ctx.get("group", "")
        if group == old:
            ctx["group"] = new
        elif group.startswith(old + "/"):
            ctx["group"] = new + group[len(old):]
    for path in list(index["groups"]):
        if path == old:
            index["groups"][new] = index["groups"].pop(path)
        elif path.startswith(old + "/"):
            index["groups"][new + path[len(old):]] = index["groups"].pop(path)
    save_index(index)


# ── live session detection ───────────────────────────────────────────────────

def live_sessions(agent_rows):
    """session id -> agent row, for the claude windows we can identify.

    A resumed session carries its id in argv. A fresh one does not, so fall back
    to the newest unclaimed transcript in that window's project directory.
    """
    found = {}
    pending = []
    for row in agent_rows:
        if row["agent"] != "claude":
            continue
        match = re.search(r"--resume\s+([0-9a-f-]{36})", row["argv"])
        if match:
            found[match.group(1)] = row
        else:
            pending.append(row)

    claimed = set(found)
    # Higher pid started later, so it owns the more recent transcript.
    for row in sorted(pending, key=lambda r: r["pid"], reverse=True):
        directory = os.path.join(PROJECTS, slugify(row["cwd"]))
        try:
            candidates = sorted(
                glob.glob(os.path.join(directory, "*.jsonl")),
                key=os.path.getmtime,
                reverse=True,
            )
        except OSError:
            continue
        for path in candidates:
            sid = os.path.basename(path)[: -len(".jsonl")]
            if sid not in claimed:
                found[sid] = row
                claimed.add(sid)
                break
    return found


# ── actions ──────────────────────────────────────────────────────────────────

def resolve_titles(live):
    """Relabel claude panes from their own transcript.

    The terminal title is per-tab as often as it is per-pane, so it is not an
    identity; the session behind the pane is.
    """
    for sid, row in live.items():
        path = os.path.join(PROJECTS, slugify(row["cwd"]), sid + ".jsonl")
        if os.path.exists(path):
            row["title"] = session_meta(path)["title"]


def focus_window(row):
    kitty(row["socket"], "focus-window", "--match", f"id:{row['window']}")


def open_session(sid, cwd):
    socks = sockets()
    if not socks:
        return False
    shell = os.environ.get("SHELL") or "/bin/sh"
    command = f"claude --resume {shlex.quote(sid)}; exec {shlex.quote(shell)} -l"
    result = kitty(
        socks[0],
        "launch",
        "--type=tab",
        f"--cwd={cwd or HOME}",
        shell, "-l", "-i", "-c", command,
    )
    return result.returncode == 0


# ── rendering helpers ────────────────────────────────────────────────────────

def ago(ts):
    delta = time.time() - ts
    if delta < 3600:
        return f"{int(delta // 60)}m"
    if delta < 86400:
        return f"{int(delta // 3600)}h"
    return f"{int(delta // 86400)}d"


def fuzzy(query, text):
    """Every word has to appear. Deliberately not a subsequence match.

    Subsequence matching makes almost any query match almost any label, which
    would keep the full-text fallback from ever firing — and that fallback is
    the whole point of the recientes section.
    """
    if not query:
        return True
    haystack = text.lower()
    return all(term in haystack for term in query.lower().split())


STATE_MARK = {"working": "●", "idle": "○", "unknown": "·"}
STATE_ORDER = {"working": 0, "idle": 1, "unknown": 2}


def luma(colour):
    r, g, b = (int(colour[i : i + 2], 16) / 255 for i in (1, 3, 5))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def dim_colour():
    """Pick a muted palette tone that stays legible on this theme.

    base16 puts a near-background shade in colour 8, which disappears entirely
    once kitty is translucent. Colour 20 is base04, the theme's own muted
    foreground, but not every scheme defines the extended slots — so measure
    against the real background instead of trusting an index.
    """
    palette = {}
    for sock in sockets()[:1]:
        result = kitty(sock, "get-colors")
        if result.returncode != 0:
            continue
        for line in result.stdout.splitlines():
            name, _, value = line.partition(" ")
            value = value.strip()
            if len(value) == 7 and value.startswith("#"):
                palette[name] = value
    background = palette.get("background")
    if not background:
        return 20
    for index in (20, 8, 7):
        colour = palette.get(f"color{index}")
        if colour and abs(luma(colour) - luma(background)) >= 0.18:
            return index
    return 7

# Colour numbers are terminal palette indices, so they are whatever stylix
# painted kitty with. 0-7 normal, 8-15 bright.
C_DIM, C_ACCENT, C_OK, C_WARN, C_GROUP, C_INFO, C_ALERT, C_TEXT = range(1, 9)


# ── the picker ───────────────────────────────────────────────────────────────

class Picker:
    SECTIONS = ("activos", "guardados", "recientes")

    def __init__(self, screen):
        self.screen = screen
        self.index = load_index()
        self.query = ""
        self.searching = False
        self.cursor = 0
        self.offset = 0
        self.preview_offset = 0
        self.preview_cache = {}
        self.message = ""
        self.message_ok = False
        self.grep_hits = {}
        self.load_data()

    # data -------------------------------------------------------------------

    def load_data(self):
        self.agents = collect_agents()
        self.agents.sort(key=lambda r: (STATE_ORDER[r["state"]], r["cwd"]))
        self.live = live_sessions(self.agents)
        resolve_titles(self.live)

        saved_ids = set(self.index["contexts"])
        sessions = []
        for path in transcript_paths():
            sid = os.path.basename(path)[: -len(".jsonl")]
            if sid in saved_ids:
                continue
            sessions.append(path)
        sessions.sort(key=os.path.getmtime, reverse=True)
        self.recent_paths = sessions
        self.recent = [session_meta(p) for p in sessions[:RECENT_LIMIT]]
        self.build_rows()

    def terms(self):
        return [t for t in self.query.split() if t]

    def build_rows(self):
        query = self.query
        rows = []
        self.grep_hits = {}

        live_rows = []
        for row in self.agents:
            label = f"{row['agent']:<8} {shorten(row['cwd'])}"
            sid = next((s for s, r in self.live.items() if r is row), None)
            group = ""
            if sid and sid in self.index["contexts"]:
                group = self.index["contexts"][sid]["group"]
            text = f"{label} {row['title']} {group}"
            if fuzzy(query, text):
                live_rows.append(
                    {
                        "kind": "agent",
                        "section": "activos",
                        "indent": 1,
                        "agent": row,
                        "sid": sid,
                        "group": group,
                    }
                )

        saved_rows = self.saved_rows(query)

        recent_rows = []
        for meta in self.recent:
            if fuzzy(query, meta["title"] + " " + shorten(meta["cwd"])):
                recent_rows.append(
                    {"kind": "recent", "section": "recientes", "indent": 1, "meta": meta}
                )

        # Nothing matched by name: the thing you are looking for is buried in the
        # body of a session, which is exactly the case this tool exists for.
        grepped = False
        if query and not (live_rows or saved_rows or recent_rows):
            if len(query.replace(" ", "")) >= GREP_MIN_QUERY:
                hits = grep_sessions(self.terms(), self.recent_paths)
                if hits:
                    grepped = True
                    self.grep_hits = hits
                    ordered = sorted(
                        hits.items(), key=lambda kv: (-kv[1], -os.path.getmtime(kv[0]))
                    )
                    for path, count in ordered[:RECENT_LIMIT]:
                        recent_rows.append(
                            {
                                "kind": "recent",
                                "section": "recientes",
                                "indent": 1,
                                "meta": session_meta(path),
                                "hits": count,
                            }
                        )

        if live_rows:
            rows.append({"kind": "header", "section": "activos", "label": "activos"})
            rows.extend(live_rows)
        if saved_rows:
            rows.append({"kind": "header", "section": "guardados", "label": "guardados"})
            rows.extend(saved_rows)
        if recent_rows:
            label = "coincidencias en el contenido" if grepped else "recientes"
            rows.append({"kind": "header", "section": "recientes", "label": label})
            rows.extend(recent_rows)

        self.rows = rows
        if query != getattr(self, "_shown_query", None):
            # A new filter means a new list; leaving the cursor where it was
            # lands it on whatever unrelated row happens to sit at that index.
            self.cursor = 0
            self.offset = 0
            self.preview_offset = 0
        self._shown_query = query
        self.cursor = min(self.cursor, max(0, len(rows) - 1))
        if rows and rows[self.cursor]["kind"] == "header":
            self.move(1)

    def saved_rows(self, query):
        contexts = self.index["contexts"]
        rows = []
        by_group = {}
        for sid, ctx in contexts.items():
            by_group.setdefault(ctx.get("group", ""), []).append((sid, ctx))

        for path in group_nodes(self.index):
            parts = path.split("/")
            hidden = any(collapsed(self.index, "/".join(parts[:i])) for i in range(1, len(parts)))
            if hidden and not query:
                continue
            total = sum(
                len(members)
                for group, members in by_group.items()
                if group == path or group.startswith(path + "/")
            )
            rows.append(
                {
                    "kind": "group",
                    "section": "guardados",
                    "indent": len(parts),
                    "path": path,
                    "name": parts[-1],
                    "count": total,
                }
            )
            if collapsed(self.index, path) and not query:
                continue
            for sid, ctx in sorted(by_group.get(path, []), key=lambda kv: kv[1]["name"].lower()):
                text = f"{ctx['name']} {shorten(ctx.get('cwd', ''))}"
                if not fuzzy(query, text):
                    continue
                rows.append(
                    {
                        "kind": "saved",
                        "section": "guardados",
                        "indent": len(parts) + 1,
                        "sid": sid,
                        "ctx": ctx,
                    }
                )

        if query:
            # Drop groups that ended up with nothing under them.
            kept = []
            for i, row in enumerate(rows):
                if row["kind"] != "group":
                    kept.append(row)
                    continue
                rest = rows[i + 1:]
                has_child = any(
                    r["kind"] == "saved" and r["indent"] > row["indent"]
                    for r in rest[: _run_length(rest, row["indent"])]
                )
                if has_child:
                    kept.append(row)
            rows = kept
        return rows

    # movement ---------------------------------------------------------------

    def move(self, step):
        if not self.rows:
            return
        i = self.cursor
        for _ in range(len(self.rows)):
            i = (i + step) % len(self.rows)
            if self.rows[i]["kind"] != "header":
                self.cursor = i
                self.preview_offset = 0
                return

    def move_page(self, step):
        height = max(1, self.screen.getmaxyx()[0] - 4)
        for _ in range(height // 2):
            self.move(step)

    def jump_section(self, step):
        if not self.rows:
            return
        current = self.rows[self.cursor]["section"]
        order = [s for s in self.SECTIONS if any(r["section"] == s for r in self.rows)]
        if current not in order:
            return
        target = order[(order.index(current) + step) % len(order)]
        for i, row in enumerate(self.rows):
            if row["section"] == target and row["kind"] != "header":
                self.cursor = i
                self.preview_offset = 0
                return

    def edge(self, last):
        self.cursor = len(self.rows) - 1 if last else 0
        if self.rows and self.rows[self.cursor]["kind"] == "header":
            self.move(-1 if last else 1)

    def current(self):
        return self.rows[self.cursor] if self.rows else None

    def notify(self, text, ok=False):
        self.message = text
        self.message_ok = ok

    # preview ----------------------------------------------------------------

    def preview_lines(self, row):
        key = self.preview_key(row)
        if key in self.preview_cache:
            return self.preview_cache[key]
        lines = self.build_preview(row)
        self.preview_cache[key] = lines
        return lines

    def preview_key(self, row):
        if row["kind"] == "agent":
            return ("agent", row["agent"]["window"], time.time() // 3)
        if row["kind"] == "group":
            return ("group", row["path"])
        if row["kind"] == "saved":
            return ("saved", row["sid"])
        return ("recent", row["meta"]["id"], self.query if self.grep_hits else "")

    def build_preview(self, row):
        if row["kind"] == "agent":
            agent = row["agent"]
            result = kitty(
                agent["socket"], "get-text",
                "--match", f"id:{agent['window']}",
                "--extent", "screen",
            )
            body = result.stdout if result.returncode == 0 else result.stderr
            return [(C_TEXT, line) for line in body.splitlines()]

        if row["kind"] == "group":
            members = [
                ctx for ctx in self.index["contexts"].values()
                if ctx.get("group") == row["path"] or ctx.get("group", "").startswith(row["path"] + "/")
            ]
            out = [(C_GROUP, row["path"]), (C_DIM, f"{len(members)} contextos"), (C_TEXT, "")]
            for ctx in sorted(members, key=lambda c: c["name"].lower()):
                out.append((C_TEXT, "  " + ctx["name"]))
                out.append((C_DIM, "    " + shorten(ctx.get("cwd", ""))))
            return out

        if row["kind"] == "saved":
            ctx = row["ctx"]
            path = ctx.get("origin", "")
            if not os.path.exists(path):
                path = copy_path(row["sid"])
            head = [
                (C_ACCENT, ctx["name"]),
                (C_DIM, shorten(ctx.get("cwd", ""))),
                (C_DIM, f"grupo {ctx.get('group', '')}  ·  guardado {ctx.get('saved_at', '')[:10]}"),
                (C_TEXT, ""),
            ]
            return head + self.prompt_lines(path)

        meta = row["meta"]
        head = [
            (C_ACCENT, meta["title"]),
            (C_DIM, shorten(meta["cwd"])),
            (C_DIM, f"hace {ago(meta['mtime'])}  ·  {meta['id'][:8]}"),
            (C_TEXT, ""),
        ]
        if self.grep_hits and meta["path"] in self.grep_hits:
            head.append((C_WARN, f"{self.grep_hits[meta['path']]} coincidencias"))
            head.append((C_TEXT, ""))
            body = []
            for ts, text in grep_excerpt(meta["path"], self.terms()):
                body.append((C_INFO, ts))
                body.extend((C_TEXT, "  " + part) for part in text.splitlines())
                body.append((C_TEXT, ""))
            return head + body
        return head + self.prompt_lines(meta["path"])

    def prompt_lines(self, path):
        out = []
        for ts, text in session_prompts(path):
            out.append((C_INFO, ts))
            for part in squash(text, 400).splitlines():
                out.append((C_TEXT, "  " + part))
            out.append((C_TEXT, ""))
        return out or [(C_DIM, "sin prompts legibles en este transcript")]

    # drawing ----------------------------------------------------------------

    def label_of(self, row):
        pad = "  " * row.get("indent", 0)
        if row["kind"] == "header":
            return row["label"].upper(), C_DIM
        if row["kind"] == "agent":
            agent = row["agent"]
            mark = STATE_MARK[agent["state"]]
            colour = {"working": C_OK, "idle": C_WARN}.get(agent["state"], C_DIM)
            tail = f"  [{row['group']}]" if row["group"] else ""
            return (
                f"{pad}{mark} {agent['agent']:<7} {shorten(agent['cwd']):<26} "
                f"{agent['title']}{tail}"
            ), colour
        if row["kind"] == "group":
            # A filter expands everything, so the arrow must not claim otherwise.
            arrow = "▸" if collapsed(self.index, row["path"]) and not self.query else "▾"
            return f"{pad}{arrow} {row['name']}  ({row['count']})", C_GROUP
        if row["kind"] == "saved":
            live = "●" if row["sid"] in self.live else "★"
            colour = C_OK if row["sid"] in self.live else C_ACCENT
            return f"{pad}{live} {row['ctx']['name']}", colour
        meta = row["meta"]
        hits = f"  {row['hits']}×" if row.get("hits") else ""
        return (
            f"{pad}  {meta['title'][:46]:<46} {shorten(meta['cwd'])} · {ago(meta['mtime'])}{hits}"
        ), C_TEXT

    def draw(self):
        screen = self.screen
        screen.erase()
        height, width = screen.getmaxyx()
        left = max(34, width // 2)

        title = (
            f" agents   {len(self.agents)} activos"
            f"  ·  {len(self.index['contexts'])} guardados"
            f"  ·  {len(self.recent)} recientes"
        )
        self.put(0, 0, title.ljust(width - 1), C_ACCENT, curses.A_BOLD)

        body = height - 2
        if self.cursor < self.offset:
            self.offset = self.cursor
        if self.cursor >= self.offset + body:
            self.offset = self.cursor - body + 1

        for i in range(body):
            idx = self.offset + i
            if idx >= len(self.rows):
                break
            row = self.rows[idx]
            text, colour = self.label_of(row)
            attr = curses.A_REVERSE if idx == self.cursor else 0
            if row["kind"] == "header":
                attr |= curses.A_BOLD
            self.put(1 + i, 0, text[: left - 1].ljust(left - 1), colour, attr)

        for i in range(body):
            self.put(1 + i, left - 1, "│", C_DIM)

        row = self.current()
        if row:
            lines = self.preview_lines(row)
            self.preview_offset = max(0, min(self.preview_offset, max(0, len(lines) - body)))
            visible = lines[self.preview_offset : self.preview_offset + body]
            for i, (colour, text) in enumerate(visible):
                self.put(1 + i, left + 1, text[: width - left - 2], colour)

        if self.searching:
            footer = f"/{self.query}"
            colour = C_WARN
        elif self.message:
            footer = self.message
            colour = C_OK if self.message_ok else C_ALERT
        else:
            footer = (
                "j/k mover  h/l sección  g/G extremos  enter abrir·plegar  "
                "a guardar  r renombrar  d quitar  / buscar  ? ayuda  q salir"
            )
            colour = C_DIM
            if self.query:
                footer = f"filtro: {self.query}   ·   esc para limpiar"
                colour = C_WARN
        self.put(height - 1, 0, footer[: width - 1].ljust(width - 1), colour)
        screen.refresh()

    def put(self, y, x, text, colour=C_TEXT, attr=0):
        try:
            self.screen.addstr(y, x, text, curses.color_pair(colour) | attr)
        except curses.error:
            pass  # bottom-right cell always raises

    # modals -----------------------------------------------------------------

    def ask(self, title, initial="", choices=()):
        """A one-line prompt with optional completion over existing values."""
        text = initial
        pick = 0
        while True:
            height, width = self.screen.getmaxyx()
            options = [c for c in choices if fuzzy(text, c)] if choices else []
            options = options[:8]
            box_height = len(options) + 2
            top = max(1, height - box_height - 2)
            for i in range(box_height):
                self.put(top + i, 0, " " * (width - 1), C_TEXT, curses.A_REVERSE)
            self.put(top, 1, title[: width - 3], C_ACCENT, curses.A_REVERSE | curses.A_BOLD)
            for i, option in enumerate(options):
                attr = curses.A_REVERSE | (curses.A_BOLD if i == pick else 0)
                marker = "›" if i == pick else " "
                self.put(top + 1 + i, 1, f"{marker} {option}"[: width - 3], C_TEXT, attr)
            self.put(top + box_height - 1, 1, ("» " + text)[: width - 3], C_WARN, curses.A_REVERSE)
            self.screen.refresh()

            key = self.screen.getch()
            if key == 27:
                return None
            if key in (curses.KEY_ENTER, 10, 13):
                return text.strip() or (options[pick] if options else "")
            if key == 9 and options:  # tab completes to the highlighted option
                text = options[pick]
            elif key == curses.KEY_DOWN and options:
                pick = (pick + 1) % len(options)
            elif key == curses.KEY_UP and options:
                pick = (pick - 1) % len(options)
            elif key in (curses.KEY_BACKSPACE, 127, 8):
                text = text[:-1]
                pick = 0
            elif 32 <= key < 127:
                text += chr(key)
                pick = 0

    def confirm(self, title, lines):
        height, width = self.screen.getmaxyx()
        box = len(lines) + 3
        top = max(1, (height - box) // 2)
        for i in range(box):
            self.put(top + i, 0, " " * (width - 1), C_TEXT, curses.A_REVERSE)
        self.put(top, 2, title[: width - 4], C_ALERT, curses.A_REVERSE | curses.A_BOLD)
        for i, line in enumerate(lines):
            self.put(top + 2 + i, 2, line[: width - 4], C_TEXT, curses.A_REVERSE)
        self.put(top + box - 1, 2, "y confirmar   ·   cualquier otra tecla cancela", C_DIM, curses.A_REVERSE)
        self.screen.refresh()
        return self.screen.getch() in (ord("y"), ord("Y"))

    def help(self):
        lines = [
            "j / k        bajar / subir            enter   grupo → plegar o desplegar",
            "h / l        sección anterior / sig.          contexto → abrir",
            "g / G        primera / última         a       guardar en un grupo (o mover)",
            "PgUp/PgDn    media página             r       renombrar contexto o grupo",
            "J / K        scroll del preview       d       dejar de guardar",
            "/            buscar (esc limpia)      q       salir",
            "",
            "Sin atajos con control: kitty se queda con ctrl+hjkl para sus ventanas.",
            "Si el nombre no matchea nada, / busca dentro del contenido de las sesiones.",
        ]
        height, width = self.screen.getmaxyx()
        top = max(1, (height - len(lines) - 3) // 2)
        for i in range(len(lines) + 3):
            self.put(top + i, 0, " " * (width - 1), C_TEXT, curses.A_REVERSE)
        self.put(top, 2, "teclas", C_ACCENT, curses.A_REVERSE | curses.A_BOLD)
        for i, line in enumerate(lines):
            self.put(top + 2 + i, 2, line[: width - 4], C_TEXT, curses.A_REVERSE)
        self.screen.refresh()
        self.screen.getch()

    # actions ----------------------------------------------------------------

    def meta_of(self, row):
        if row["kind"] == "recent":
            return row["meta"]
        if row["kind"] == "saved":
            ctx = row["ctx"]
            return {
                "id": row["sid"],
                "path": ctx.get("origin", ""),
                "cwd": ctx.get("cwd", ""),
                "title": ctx["name"],
                "mtime": 0,
            }
        if row["kind"] == "agent" and row["sid"]:
            # Not the window title: kitty hands us the *tab* title when the pane
            # is not the one drawing it, so two panes in a tab look identical.
            path = os.path.join(
                PROJECTS, slugify(row["agent"]["cwd"]), row["sid"] + ".jsonl"
            )
            if os.path.exists(path):
                return session_meta(path)
            return {
                "id": row["sid"],
                "path": "",
                "cwd": row["agent"]["cwd"],
                "title": row["agent"]["title"],
                "mtime": 0,
            }
        return None

    def activate(self, row):
        if row["kind"] == "group":
            toggle_group(self.index, row["path"])
            self.build_rows()
            return False
        if row["kind"] == "agent":
            focus_window(row["agent"])
            return True
        sid = row["sid"] if row["kind"] == "saved" else row["meta"]["id"]
        if sid in self.live:
            focus_window(self.live[sid])
            return True
        if row["kind"] == "saved":
            restore(sid, row["ctx"])
            cwd = row["ctx"].get("cwd", "")
        else:
            cwd = row["meta"]["cwd"]
        if not open_session(sid, cwd):
            self.notify("no pude hablar con kitty para abrir el tab")
            return False
        return True

    def save_context(self, row):
        meta = self.meta_of(row)
        if not meta:
            self.notify("esta fila no es un contexto de claude")
            return
        if not meta["path"]:
            guess = os.path.join(PROJECTS, slugify(meta["cwd"]), meta["id"] + ".jsonl")
            if not os.path.exists(guess):
                self.notify("no encuentro el transcript de esa sesión")
                return
            meta = dict(meta, path=guess)
        current = self.index["contexts"].get(meta["id"], {}).get("group", "")
        group = self.ask(
            "grupo (se crea si no existe)",
            current,
            choices=group_nodes(self.index),
        )
        if not group:
            return
        pin(self.index, meta, group.strip("/"))
        self.notify(f"guardado en {group}", ok=True)
        self.load_data()

    def rename(self, row):
        if row["kind"] == "group":
            new = self.ask("nuevo nombre del grupo", row["path"])
            if new and new != row["path"]:
                rename_group(self.index, row["path"], new.strip("/"))
                self.build_rows()
            return
        if row["kind"] != "saved":
            self.notify("sólo se renombran contextos guardados y grupos")
            return
        new = self.ask("nuevo nombre", row["ctx"]["name"])
        if new:
            row["ctx"]["name"] = new
            save_index(self.index)
            self.build_rows()

    def drop(self, row):
        if row["kind"] != "saved":
            self.notify("sólo se quitan contextos guardados")
            return
        sid = row["sid"]
        ctx = row["ctx"]
        origin = ctx.get("origin", "")
        if origin and os.path.exists(origin):
            warning = "el original sigue en ~/.claude/projects"
        else:
            warning = "ESTA ES LA ÚNICA COPIA QUE QUEDA — se pierde para siempre"
        if self.confirm(f"quitar «{ctx['name']}»", [warning]):
            unpin(self.index, sid)
            self.preview_cache.clear()
            self.load_data()

    # loop -------------------------------------------------------------------

    def run(self):
        while True:
            self.draw()
            key = self.screen.getch()
            self.message = ""
            self.message_ok = False

            if key == curses.KEY_RESIZE:
                self.preview_cache.clear()
                continue

            if self.searching:
                if key == 27:
                    self.searching = False
                    self.query = ""
                    self.build_rows()
                elif key in (curses.KEY_ENTER, 10, 13):
                    self.searching = False
                elif key in (curses.KEY_BACKSPACE, 127, 8):
                    self.query = self.query[:-1]
                    self.build_rows()
                elif 32 <= key < 127:
                    self.query += chr(key)
                    self.build_rows()
                continue

            row = self.current()
            if key in (ord("q"), 27):
                if self.query:
                    self.query = ""
                    self.build_rows()
                    continue
                return
            if key == ord("j"):
                self.move(1)
            elif key == ord("k"):
                self.move(-1)
            elif key == ord("l"):
                self.jump_section(1)
            elif key == ord("h"):
                self.jump_section(-1)
            elif key == ord("g"):
                self.edge(False)
            elif key == ord("G"):
                self.edge(True)
            elif key == curses.KEY_NPAGE:
                self.move_page(1)
            elif key == curses.KEY_PPAGE:
                self.move_page(-1)
            elif key == ord("J"):
                self.preview_offset += 5
            elif key == ord("K"):
                self.preview_offset = max(0, self.preview_offset - 5)
            elif key == ord("/"):
                self.searching = True
                self.query = ""
                self.build_rows()
            elif key == ord("?"):
                self.help()
            elif key == ord("a") and row:
                self.save_context(row)
            elif key == ord("r") and row:
                self.rename(row)
            elif key == ord("d") and row:
                self.drop(row)
            elif key in (curses.KEY_ENTER, 10, 13) and row:
                if self.activate(row):
                    return


def _run_length(rows, indent):
    """How many rows belong to the subtree that follows a group at `indent`."""
    for i, row in enumerate(rows):
        if row["indent"] <= indent:
            return i
    return len(rows)


def start(screen):
    curses.curs_set(0)
    curses.use_default_colors()
    dim = dim_colour()
    for pair in range(1, 9):
        # Palette indices, i.e. whatever stylix painted the terminal with.
        curses.init_pair(pair, {C_DIM: dim, C_ACCENT: 4, C_OK: 2, C_WARN: 3,
                                C_GROUP: 5, C_INFO: 6, C_ALERT: 1, C_TEXT: -1}[pair], -1)
    try:
        curses.set_escdelay(25)
    except (AttributeError, curses.error):
        pass
    picker = Picker(screen)
    # Refreshing every saved copy can touch hundreds of MB, so never make the
    # first paint wait on it.
    threading.Thread(target=sync_all, args=(picker.index,), daemon=True).start()
    picker.run()


def main(argv):
    if "--list" in argv:
        rows = collect_agents()
        resolve_titles(live_sessions(rows))
        for row in rows:
            print(f"{STATE_MARK[row['state']]} {row['agent']:<9} {shorten(row['cwd'])}  {row['title']}")
        index = load_index()
        for sid, ctx in sorted(index["contexts"].items(), key=lambda kv: kv[1]["group"]):
            print(f"★ {ctx['group']:<24} {ctx['name']}  ({sid[:8]})")
        return 0
    if "--sync" in argv:
        sync_all(load_index())
        return 0
    os.makedirs(TRANSCRIPTS, exist_ok=True)
    curses.wrapper(start)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

