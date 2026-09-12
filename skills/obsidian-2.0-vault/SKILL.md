---
name: obsidian-2.0-vault
description: "How to work with the ~/Obsidian-2.0 vault: searching content, linking notes, creating/editing via obsidian-cli or direct file edits, templates, flashcards. Formatting and structure rules live in the vault's CLAUDE.md — this skill covers the mechanics."
---

# Obsidian-2.0 Vault — mechanics

Vault path: `~/Obsidian-2.0`.

**Before writing any note, read `~/Obsidian-2.0/CLAUDE.md`.** It owns formatting, folder taxonomy, frontmatter tiers, tags, note division, and the Cornell rule for theory notes. This matters especially when working from a session *outside* the vault directory (e.g. a NixOS config repo), where that CLAUDE.md is not auto-loaded — skipping it produces wrongly classified, wrongly tagged notes.

## Two ways to operate — when to use which

### Direct file edits (Read/Write/Edit/Grep on `~/Obsidian-2.0`)

Always available, no dependencies. Prefer for:
- Creating or rewriting whole notes
- Bulk/multi-file edits and refactors
- When Obsidian desktop may not be running

Obsidian picks up external file changes automatically; no reload needed.

### `obsidian-cli` (official CLI, v1.12+)

Talks to the **running** Obsidian desktop app via IPC; with Obsidian closed, commands fail
and direct file edits are the fallback. Invoke the `obsidian-cli` skill for the binary
name, calling convention and command reference.

Reach for it when the app's index beats grep: full-text search, backlinks, outgoing links,
orphans, unresolved wikilinks, frontmatter reads, templates, daily-note appends. Paths in
this vault are `path="LCC/Linux/nix.md"` shaped, from the vault root.

## Searching the vault — decision guide

| Need | Tool |
|---|---|
| Exact string / regex / code fragment | `Grep` on `~/Obsidian-2.0` |
| Find note by name | `Glob` pattern or `obsidian-cli file name="..."` |
| Full-text fuzzy search | `obsidian-cli search query="..."` |
| Graph questions (backlinks, orphans, broken links) | `obsidian-cli backlinks/orphans/unresolved` |
| "Does a note on X already exist?" | Both: Glob by name + Grep by keyword — **always check before creating** (editing an existing note beats creating a duplicate) |

## Linking — when

Syntax (wikilinks, embeds, block refs) lives in the `obsidian-markdown` skill; invoke it
for the how. This section owns only the vault's own policy on *when*.

- **First mention** of a concept that has (or deserves) its own note — not every repetition.
- The `Notas relacionadas: [[X]] · [[Y]]` line near the top of every technical note (required by CLAUDE.md).
- Academic cross-links per the CLAUDE.md table (MVCC → [[Teoria de Bases de Datos]], scheduling → [[Sistemas Operativos]], etc.).
- A wikilink to a nonexistent note is a valid TODO **only** if it's a topic the user would plausibly write. Don't scatter dead links to things that will never get a note. Check with `obsidian-cli unresolved` when in doubt.
- Internal = wikilinks, external URLs = markdown links. Never markdown-link to a vault note.

## Templates

Live in `Templates/`, use Templater syntax (`<% tp.file.title %>`, `<% tp.date.now("YYYY-MM-DD") %>`). Available:
- `Cornell Note Template.md` — **only when the user explicitly asks for a Cornell note**, never by default. No frontmatter. Order: Notas → Cues → Resumen. Claude fills only `## Notas`; Cues and Resumen stay empty (guide comments included) for the user to fill while studying.
- `Infra Component Template.md` — LB/ infra notes
- `Daily Note Template.md`, `Weekly Note Template.md`, `JJ Note Template.md` — auto-generated types

When creating a note of a templated type, follow the template's structure (copy it and fill), or `obsidian-cli create path="..." template="..."` if Obsidian is running. Templater placeholders only render when the note is created through Obsidian — with direct file writes, substitute the values yourself (never leave raw `<% %>` in a note).

## Flashcards (Spaced Repetition plugin)

Notes with cards need `#flashcards` or `#flashcards/topic` tag. Formats:

```markdown
Pregunta #alta
?
Respuesta multilínea, admite listas, `código`, $$LaTeX$$.

Pregunta::Respuesta            (una línea)
Pregunta:::Respuesta           (reversible, 2 cards)
La ==respuesta== oculta.       (cloze)
```

- `---` separa cards; agrupar por `## Heading`.
- Prioridad: `#alta`, `#media`.

## Special note types (auto-generated, don't restructure)

- **Daily**: `General/Journal/01 Daily/YYYY-MM-DD.md` — append via `obsidian-cli daily:append`; don't touch the dataviewjs blocks.
- **Weekly**: `General/Journal/02 Weekly/YYYY-Www.md`.
- **BJJ**: `BJJ/`, frontmatter per its template (`profesor`, `tipo_clase`, `enfoque`, `dificultad`).
- **Attachments**: media goes in `Attachments/`, embed with `![[archivo]]`.

## Dataview

The vault uses Dataview; existing query blocks in notes are load-bearing — preserve them when editing. Reading a note via `obsidian-cli read` shows the raw query, not results; that's expected.
