---
tool: __SLUG__
kind: integration            # integration | routines
covers_skills: []            # skills that use this tool (optional)
---

# __TITLE__

> **skill-tool.** Use the `## Usages` below directly (the 80 % cases), no doc-reading.
> If your action isn't listed: read `## Reference`, derive it, run it, and **add a `### Usage`**
> (gotchas included) so next time falls into the instant path.
> Keep usages lean (≲10); if it overflows, drop the ones you haven't used in a while.

## Usages (proven — use directly)

### Usage: <short action name>
<gotcha, if any — the thing that wasn't obvious from the docs>
```bash
<exact copy-paste command, values templated as <placeholders>>
```

## Reference (read only if no usage above fits)

### Access / Auth
- <token / OAuth / config location>

### Commands
```bash
<full command surface, edge cases, rare flags>
```

### Notes / IDs
- <known ids, gotchas, anything non-discoverable>

## Rules
- Outward-facing actions (send, POST, publish, write) → preview + Y/n confirm before running.
  <delete this section if the tool is read-only / local-only>
