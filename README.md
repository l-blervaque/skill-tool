# skill-tool

The **skill-tool** pattern — a lightweight alternative to a full Claude skill, for tool/integration commands
you run *often* and that are *tiny* (send a message, create a draft, add a label).

One markdown file per tool, structured so the common-case commands are usable **instantly with zero
doc-reading**, while the full API reference stays one scroll away for the rare cases. It self-improves:
the first time you work out a new command, you save it back as a `### Usage` so next time is instant.

## Why

- Full **skill** = thin description + heavy body loaded on demand → great for *heavy, rare* workflows.
- **skill-tool** = frequent commands inline + lazy reference → great for *tiny, frequent* actions,
  where wrapping a one-liner in a skill means paying the open→read ceremony every single time.
- Not a rival to **scripts** or **MCP**: a skill-tool can call either inside its commands — and its
  proven usages become ready-made parts you assemble new skills from.

## Read this

[`SETUP.md`](./SETUP.md) — the full spec: the structure, the write-on-success loop, the cap rule,
and a worked example. Self-contained: hand the repo to Claude and say *"read SETUP.md and apply
skill-tool to my tools."*

## Contents

- [`SETUP.md`](./SETUP.md) — the spec.
- [`tools/_TEMPLATE.md`](./tools/_TEMPLATE.md) — blank skill-tool file.
- [`tools/example-google-workspace.md`](./tools/example-google-workspace.md) — worked example (placeholder IDs).
