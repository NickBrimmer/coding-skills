#!/bin/sh
# Fails when a staged skill folder has no row in the README's skills table.
# Usage: skills-table-check.sh   (reads the git index, so it checks what is about to be committed)
set -u

readme=$(git show :README.md 2>/dev/null) || exit 0

status=0
for skill in $(git ls-files '*/SKILL.md' | grep -E '^[^/]+/SKILL\.md$' | sed 's|/SKILL.md$||'); do
  if ! printf '%s\n' "$readme" | grep -qF "| \`$skill\` |"; then
    echo "skills-table-check: $skill/SKILL.md has no row in the README skills table" >&2
    status=1
  fi
done
exit "$status"
