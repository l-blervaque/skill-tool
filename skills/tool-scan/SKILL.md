---
name: tool-scan
description: Optional one-shot bootstrap — scan existing skills to surface candidate skill-tool usages (commands they already exercise), present them grouped by tool, let the user pick which to materialize via /tool-add, then offer to discard the leftover suggestions. Pull/snapshot, never background. Use when the user runs /tool-scan.
---

# /tool-scan — Bootstrap skill-tools from existing skills

Family C (in-session generative, local writes only). Trigger: manual (`/tool-scan`).
<!-- TODO: wire Discord observability (report_start/report_success/report_error) once
     ~/.claude/lib/discord_report.py socle exists. Skipped for now — the socle is absent. -->

## What this does

Mines the existing skills for the integration commands they already run, and proposes them as
**candidate `### Usage`s** for skill-tool files — without building anything automatically. the user
picks what to materialize; the rest is offered for deletion. It is a **pull, on-demand snapshot**:
no background job, no sync. Suggestions point to their **source** (skill + script); the command is
only copied into a tool file at materialization, where it is verified against that source.

Optional by design: it may be run once, or never.

## Process

1. **Enumerate + ask scope.** Run:
   ```bash
   bash ~/.claude/skills/tool-scan/scripts/scan.sh list
   ```
   Show the skill list + the already-materialized `tools/*.md`. Then **ask the user the scan scope**
   (point of control): all skills · a named subset · include the raw `tools/*.sh` scripts too.
   Nothing is scanned deeply until he answers.

2. **Digest the chosen scope.** Run:
   ```bash
   bash ~/.claude/skills/tool-scan/scripts/scan.sh digest <slug...>   # or: digest all
   ```
   Open the specific SKILL.md / scripts only when a line needs context.

3. **Build the suggestion list (global).** Group the found commands **by tool** (the integration:
   `cwcli`→chatwork, `gws`→google-workspace, `gh`→github, `todo-tui`→todo-tui, …). For each:
   - the **candidate usage** (short action name),
   - the **source** (`skill` + `file:line`),
   - the **actual command**.
   **Cross-reference existing `tools/<tool>.md`** and drop anything already present as a `### Usage`
   (don't re-suggest what's materialized).

4. **Present + let the user pick.** Print the global list grouped by tool. the user says which tools/usages
   to add (e.g. "add chatwork all, gh issue-create, skip the rest").

5. **Materialize the picks.**
   - **New tool** → `/tool-add <slug> "<Title>"` (its scaffolder), then fill the `### Usage`(s).
   - **Existing tool** → append the `### Usage`(s) under `## Usages`, command + a one-line gotcha,
     keeping ≲10 usages (the cap rule).
   Show the diff/preview and get the user's OK before writing to an existing tool file.

6. **Offer to discard the leftovers (the end).** Propose either:
   - **discard** the un-picked suggestions → clean one-shot, zero residue (recommended default), or
   - **keep** them as a dated snapshot `tools/CANDIDATES.md` → enables "explore from the memo on a
     future miss", at the cost of a snapshot that may go stale.
   the user chooses. Do not keep the memo silently.

## Rules

- **Never background, never sync.** This is a manual snapshot; if it ever becomes a scheduled job
  or a kept-in-sync index, the design has failed (that machinery was deliberately dropped).
- The memo, if kept, **points to sources** — it must not become an authoritative copy of commands.
- Materializing into an existing tool file modifies it → preview + Y/n before writing.
- Respect the cap (≲10 usages per tool); if a pick would overflow, flag it to the user.
- English content (per skill guidelines).

## Notes

- Companion to `/tool-add` in the `/tool-*` family. Spec & rationale: this repo
  (`SETUP.md`).
- The digest regex is a heuristic — treat its output as leads, not gospel; open the source when a
  candidate is ambiguous.
