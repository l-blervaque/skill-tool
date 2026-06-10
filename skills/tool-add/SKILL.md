---
name: tool-add
description: Scaffold a new skill-tool file (tools/<slug>.md, the skill-tool structure with ## Usages + ## Reference) in the current project, and add its row to TOOLS.md. Local only — no USAGES.md, no drift tracking. Use when the user runs /tool-add <slug> "<Title>".
---

# /tool-add — Scaffold a new skill-tool

Family C (in-session generative, local writes only). Trigger: manual (`/tool-add`).
<!-- TODO: wire Discord observability (report_start/report_success/report_error) once
     ~/.claude/lib/discord_report.py socle exists. Skipped for now — the socle is absent. -->

## What this does

Creates `tools/<slug>.md` from the canonical **skill-tool** structure (a `## Usages` tier for
proven copy-paste commands, a `## Reference` tier for the lazy depth) and, if the project's
`TOOLS.md` has the `<!-- new-tool:insert-above -->` marker, inserts the capability index row.

It does **not** create a `USAGES.md` stub and does **not** touch any drift tracking — recipes live
inside the tool file, per the skill-tool spec.

## Usage

```
/tool-add <slug> "<Title>"
```
- `<slug>` — lowercase-kebab (e.g. `slack`, `pm-tool`).
- `<Title>` — human title for the index row and the file heading (e.g. `Slack — messages`).

## Process

1. **Resolve args.** Need both `<slug>` and `<Title>`. If either is missing, ask for it.
2. **Run the scaffolder** from the project root (the directory that owns `tools/`):
   ```bash
   bash ~/.claude/skills/tool-add/scripts/scaffold.sh <slug> "<Title>"
   ```
   It refuses if `tools/<slug>.md` already exists, validates the slug, writes the file, and adds
   the `TOOLS.md` row when the marker is present.
3. **Report the result** — the created path and whether the index row was added. Remind that the
   first `### Usage` gets filled later, once a real command has actually worked (write-on-success).

## Rules

- Local, non-destructive: it never overwrites an existing tool file (it errors instead).
- Never create a `USAGES.md` or wire drift tracking — that machinery was deliberately dropped.
- English content (per skill guidelines).

## Notes

- The skill-tool structure and rationale live in this repo's `SETUP.md`. This skill is the
  `/tool-add` half of the `/tool-*` family; `/tool-scan` (bootstrap
  from existing skills) is the planned companion.
