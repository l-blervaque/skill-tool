#!/usr/bin/env bash
# Scaffold a new skill-tool file in the current project: tools/<slug>.md (skill-tool structure)
# + an index row in ./TOOLS.md if present. Local only — no USAGES.md, no drift tracking.
# Usage: scaffold.sh <slug> "<Title>"   (run from the project root that owns tools/)
set -euo pipefail

slug="${1:-}"; shift || true
title="${*:-}"
if [ -z "$slug" ] || [ -z "$title" ]; then
  echo "Usage: $0 <slug> \"<Title>\"" >&2
  exit 1
fi
# slug must be lowercase-kebab
if ! printf '%s' "$slug" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "Invalid slug '$slug' (use lowercase-kebab, e.g. my-tool)." >&2
  exit 1
fi

TOOLS_DIR="$(pwd)/tools"
INDEX="$(pwd)/TOOLS.md"
dst="$TOOLS_DIR/$slug.md"

mkdir -p "$TOOLS_DIR"
[ -e "$dst" ] && { echo "Already exists: $dst" >&2; exit 1; }

# 1) the skill-tool file (canonical structure)
cat > "$dst" <<'EOF'
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
EOF
# substitute placeholders (kept out of the heredoc so backticks/quotes survive verbatim)
sed -i '' -e "s/__SLUG__/$slug/g" -e "s/__TITLE__/$title/g" "$dst"

# 2) index row in TOOLS.md, just above the marker (if both exist)
marker="<!-- new-tool:insert-above -->"
if [ -f "$INDEX" ] && grep -qF "$marker" "$INDEX"; then
  python3 - "$INDEX" "$title" "$slug" "$marker" <<'PY'
import sys
index, title, slug, marker = sys.argv[1:5]
row = f"| {title} | `tools/{slug}.md` |\n"
out = []
for ln in open(index).read().splitlines(keepends=True):
    if marker in ln:
        out.append(row)
    out.append(ln)
open(index, "w").write("".join(out))
PY
  index_msg="index row added to TOOLS.md"
else
  index_msg="TOOLS.md not updated (no file or no '$marker' marker) — add the row by hand if needed"
fi

echo "Created: $dst"
echo "         $index_msg"
echo "Next: fill the first ### Usage once you've run a real command that works."
