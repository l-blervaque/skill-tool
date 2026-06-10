# skill-tool

A **skill-tool** is a single markdown file per tool/integration, structured so the common-case
commands are usable **instantly, with zero doc-reading** — while the full API reference stays one
scroll away for the rare cases.

It's the right unit for **tiny actions used frequently** (send a message, create a draft, add a
label), where a full Claude skill would be the wrong tool.

---

## 1. Why not just a skill?

It comes down to where a capability sits on the **frequency × payload-size** curve.

- A real **skill** = a thin always-on description + a heavy body loaded on invocation. Optimal for
  **heavy body, rare use**: you pay the open→read→execute ceremony once in a while, it's worth it.
- An **integration call** is the opposite: **tiny payload, very frequent**. "Send a message" is a
  one-line command. Wrapping it in a skill means paying the open→read ceremony *every time* just to
  fetch a one-liner.

> **Procedure used rarely → Skill. Tiny action used often → skill-tool.**

A skill-tool keeps the frequent commands inline (no ceremony) and the heavy reference lazy.

### Why not just an MCP?

An MCP exposes typed tools — but every tool's schema sits **always-on** in context, and it's code +
a running process to build, host, and keep alive. A skill-tool wraps a CLI you already have, loads
on demand, and grows by appending a `### Usage` (one line) instead of redeploying code.

> No CLI + typed/shared tool → MCP. A CLI you already drive → skill-tool.

### Why not just a script?

A script encapsulates *procedure* (multi-step logic); a skill-tool remembers *which command + the
gotchas* for a frequent one-shot action. Wrapping a one-liner in a script is just one more file to
maintain.

> Multi-step logic → script. One command to remember → skill-tool.

**Neither is a rival.** A skill-tool can call a script or invoke an MCP tool right inside its
commands — both become building blocks it reaches for when an action needs them. And it works both
ways: a skill-tool's proven `### Usage`s are ready-made parts when you author a new skill — you
assemble it from commands that already work instead of deriving them from scratch.

---

## 2. Structure — two tiers in one file

`tools/<tool>.md`:

- **Tier A — `## Usages`** (top): proven, copy-paste-ready recipes for the 80 % cases, **gotchas
  inline**. Act from these directly — no doc-reading.
- **Tier B — `## Reference`** (below): the full, possibly-ugly API surface (auth, IDs, rare flags).
  Read only when no usage above fits.

Canonical layout (see [`tools/example-google-workspace.md`](./tools/example-google-workspace.md)):

````markdown
---
tool: <slug>
kind: integration
covers_skills: [..]          # optional: skills that use this tool
---

# <Title>

> **skill-tool.** Use the `## Usages` below directly (the 80 % cases), no doc-reading.
> If your action isn't listed: read `## Reference`, derive it, run it, and **add a `### Usage`**.
> Keep usages lean (≲10); if it overflows, drop the ones you haven't used in a while.

## Usages (proven — use directly)

### Usage: <short action name>
<gotcha, if any>
```bash
<exact copy-paste command, values templated as <placeholders>>
```

## Reference (read only if no usage above fits)
<auth, IDs, full command surface, edge cases>

## Rules
- Outward-facing actions (send, POST, publish, write) → preview + confirm.
  <delete if the tool is read-only / local-only>
````

---

## 3. The write-on-success loop (what makes it self-improving)

1. **Usage exists** (`### Usage: …`) → load it, tweak values, run. Instant. No prep.
2. **Usage missing** → read `## Reference`, derive the command, run it. **If it succeeds, add a new
   `### Usage`** (with the gotchas you hit) so next time falls into path 1.

Over time each tool file converges to "exactly the commands you actually use, ready to fire."

---

## 4. The cap rule (a *rule*, not machinery)

Keep ≲10 usages per tool. If a file overflows, **prune by eye** the recipes you haven't used
recently.

Deliberately **no counter, no ranking, no eviction script.** A tool realistically holds 5–15 short
recipes, never hundreds; a markdown file that small costs nothing to read. Ranking/LFU/log machinery
was considered and dropped as YAGNI — keep it in reserve only if a file ever becomes genuinely
unwieldy.

---

## 5. Files in this repo

- [`tools/_TEMPLATE.md`](./tools/_TEMPLATE.md) — blank skill-tool file to copy for a new tool.
- [`tools/example-google-workspace.md`](./tools/example-google-workspace.md) — a worked example
  (real shape, IDs replaced with placeholders).

To adopt it: drop a `tools/` folder in your project, copy the template per integration, and fill the
`## Usages` as you go via the write-on-success loop (§3).
