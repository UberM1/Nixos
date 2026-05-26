---
name: obsidian-2.0-vault
description: "Vault-specific patterns for ~/Obsidian-2.0: flashcards, metadata, structure"
---

# Obsidian-2.0 Vault Patterns

This skill provides patterns specific to the user's Obsidian vault at `~/Obsidian-2.0`.

## Vault Structure

```
~/Obsidian-2.0/
├── LB/                    # Work/infrastructure (Kubernetes, Vault, incidents)
├── LCC/                   # University coursework (IA, SO, Redes, etc.)
├── General/               # Personal (Home Lab, Journal, Routines)
│   └── Journal/
│       ├── 01 Daily/      # Daily notes (YYYY-MM-DD.md)
│       └── 02 Weekly/     # Weekly notes (YYYY-Www.md)
├── DnD/                   # D&D campaign materials
├── BJJ/                   # Jiu-Jitsu training notes
├── Templates/             # Note templates
├── Attachments/           # Media files
├── Excalidraw/            # Diagrams
└── Documentos/            # PDFs
```

## Flashcard Creation

Uses Spaced Repetition plugin (obsidian-spaced-repetition).

### Required Tag
All flashcard notes MUST include `#flashcards` or `#flashcards/topic` tag.

### Card Formats

**Multiline Q&A (preferred):**
```markdown
Question text here #alta
?
Answer text here. Can include:
- Bullet points
- **Bold text**
- `code blocks`
- $$LaTeX formulas$$
```

**Single line:**
```markdown
Question::Answer
Question:::Answer  (reversed, creates 2 cards)
```

**Cloze deletion:**
```markdown
The ==answer== is hidden during review.
```

### Priority Tags
- `#alta` - High priority, review more often
- `#media` - Medium priority

### Card Structure
- Use `---` (horizontal rule) to separate individual cards
- Group by topic using `## Headings`
- Example file structure:

```markdown
# Flashcards: Topic Name
#flashcards/topic

---

## Section 1

Question 1 #alta
?
Answer 1

---

Question 2 #media
?
Answer 2

---
```

### Formulas in Cards
Use LaTeX for math:
```markdown
What is the Shannon theorem? #alta
?
$$C = B \log_2(1 + S/N) \text{ bits/seg}$$
- B: bandwidth
- S/N: signal-to-noise ratio
```

## Source Metadata

When creating notes from external sources (web, books, papers), include frontmatter with sources as a list:

```yaml
---
sources:
  - "https://example.com/article"
  - "Book Title by Author"
  - "[[Internal Note]]"
tags:
  - type/source
  - topic/relevant-topic
---
```

### For Web Clippings
```yaml
---
sources:
  - "https://example.com/article"
  - "https://another-source.com/page"
date_published: YYYY-MM-DD
date_accessed: YYYY-MM-DD
tags:
  - type/clipping
---
```

## Tag Conventions

Use `type/*` prefix for categorization:
- `type/daily-note` - Journal entries
- `type/weekly-note` - Weekly reviews
- `type/jiujitsu-class` - BJJ training
- `type/source` - External source notes
- `type/clipping` - Web clippings
- `type/flashcards` - Flashcard decks
- `type/infra-component` - Infrastructure software (ArgoCD, Vault, Falco, etc.)

## Infrastructure Component Notes

For DevOps/infrastructure software documentation. Template at `Templates/Infra Component Template.md`.

Frontmatter:
```yaml
---
component: "component-name"
category: "security" | "gitops" | "networking" | "observability" | "storage" | "runtime"
tags:
  - type/infra-component
docs:
  - "https://official-docs.example.com"
sources:
  - "https://tutorial-or-reference.com"
---
```

Structure includes:
- Overview table (version, namespace, helm chart, port)
- Installation (prerequisites, helm install, values)
- Configuration (env vars, secrets path)
- Operations (health, logs, restart, port-forward commands)
- Troubleshooting (issue/symptoms/cause/fix format)
- Backup/Restore
- Upgrade procedure
- Changelog

Place infra component notes in `LB/` folder.

## BJJ Note Structure

For Jiu-Jitsu training notes, use frontmatter:
```yaml
---
date: YYYY-MM-DD
tags:
  - type/jiujitsu-class
profesor: "Name"
tipo_clase: "gi" | "no-gi"
enfoque: "guardia" | "pase" | "takedown" | "submission"
dificultad: "basico" | "intermedio" | "avanzado"
---

## Que vimos
- **Tecnica:** Name
- **Posicion:** Starting position
- **Objetivo:** Goal
- **Pasos:**
  1. Step 1
  2. Step 2
- **Observaciones:** Notes

## Sparring
- Notes from rolling

## Observaciones personales
- Personal insights
```

## Daily Notes

Auto-generated in `General/Journal/01 Daily/` with format `YYYY-MM-DD.md`.

Key frontmatter fields:
```yaml
---
date: YYYY-MM-DD
tags:
  - type/daily-note
journal-date: <% tp.file.title %>
log-sleep-hours:
log-healthy-eating:
---
```

## File Operations

Vault path: `~/Obsidian-2.0`

When creating/editing files:
- Use wikilinks `[[Note Name]]` for internal links
- Use markdown links `[text](url)` only for external URLs
- Attachments go in `Attachments/` folder

## Dataview Usage

The vault uses Dataview for dynamic queries. Common patterns:
```dataview
LIST FROM #type/daily-note WHERE date >= date(today) - dur(7 days)
```

```dataviewjs
dv.table(["File", "Date"], dv.pages("#flashcards").map(p => [p.file.link, p.date]))
```
