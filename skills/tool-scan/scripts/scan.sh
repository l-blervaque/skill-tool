#!/usr/bin/env bash
# Enumerate skills + already-materialized tools, and dump a command digest for chosen skills.
# Raw material for /tool-scan — Claude reasons over the output to propose candidate usages.
# Usage:
#   scan.sh list                  # all skills (slug — description) + existing tools/ files
#   scan.sh digest <slug...>|all  # command markers found in the given skills' dirs
set -euo pipefail
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"

# command-ish markers that hint at an integration call (kept specific to avoid prose noise)
CMD_RE='cwcli|(^|[^[:alnum:]])gws([^[:alnum:]]|$)|todo-tui|(^|[^[:alnum:]])gh +[a-z]|curl |googleapis|api\.chatwork|drafts +(create|list|delete)|labels +list|spreadsheets|python3 +|uv run|\.local/bin'

frontmatter_field() { # <file> <field>
  awk -v f="$2" '/^---/{n++; next} n==1 && $0 ~ "^"f":" {sub("^"f": *",""); print; exit}' "$1"
}

mode="${1:-list}"; shift || true
case "$mode" in
  list)
    echo "## Skills (slug — description)"
    for d in "$SKILLS_DIR"/*/; do
      s="$(basename "$d")"; [ -f "$d/SKILL.md" ] || continue
      desc="$(frontmatter_field "$d/SKILL.md" description)"
      printf -- '- %s — %s\n' "$s" "${desc:0:120}"
    done
    echo
    echo "## Already-materialized tools in $(pwd)/tools"
    if [ -d "$(pwd)/tools" ]; then
      for f in "$(pwd)"/tools/*.md; do [ -e "$f" ] || continue; echo "- $(basename "$f")"; done
    else
      echo "- (no tools/ dir in current project)"
    fi
    ;;
  digest)
    [ "$#" -gt 0 ] || { echo "usage: scan.sh digest <slug...>|all" >&2; exit 1; }
    [ "$1" = "all" ] && set -- $(for d in "$SKILLS_DIR"/*/; do basename "$d"; done)
    for s in "$@"; do
      d="$SKILLS_DIR/$s"
      [ -f "$d/SKILL.md" ] || { echo "### $s (no SKILL.md, skipped)"; echo; continue; }
      echo "### $s"
      # $d may be a symlink (skills are often symlinked); BSD grep -r/-R won't descend a
      # symlinked dir argument, so resolve to the physical path first.
      real="$(cd "$d" && pwd -P)"
      grep -RnEi "$CMD_RE" "$real" 2>/dev/null | sed "s#$real/##" | sed 's/^/  /' | head -40 || true
      echo
    done
    ;;
  *) echo "usage: scan.sh [list | digest <slug...>|all]" >&2; exit 1;;
esac
