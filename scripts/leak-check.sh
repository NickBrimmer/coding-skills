#!/bin/sh
# Fails when text holds private information: generic patterns live here, private terms in a denylist outside the repo.
# Usage: leak-check.sh [--label NAME] [FILE...]   (reads stdin when no FILE is given)
# Exit: 0 clean, 1 hit, 2 no usable denylist (fails closed).
set -u

denylist="${CODING_SKILLS_DENYLIST:-$HOME/.config/coding-skills/denylist.txt}"
label=stdin
if [ "${1:-}" = "--label" ]; then
  label=$2
  shift 2
fi

patterns=$(mktemp)
text=$(mktemp)
trap 'rm -f "$patterns" "$text"' EXIT

# A blank line in a grep -f pattern file matches everything, so strip blanks and comments.
if ! grep -vE '^[[:space:]]*(#|$)' "$denylist" >"$patterns" 2>/dev/null; then
  echo "leak-check: no usable denylist at $denylist; refusing to pass (see README, Privacy)" >&2
  exit 2
fi

cat "$@" >"$text"

hits=$(
  {
    grep -noiwE -f "$patterns" "$text"
    grep -nowE '[[:upper:]][[:upper:][:digit:]]{1,9}-[[:digit:]]+' "$text" |
      grep -vE ':(TICKET|ABC|UTF|SHA|ISO|RFC|WCAG|ES)-[0-9]+$'
    grep -noE '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}' "$text" |
      grep -vE ':(git@github\.com|[^:]*@example\.(com|org))$'
    grep -noE '/(Users|home)/[A-Za-z0-9._-]+' "$text"
    grep -nowE '[A-Za-z0-9-]+\.(internal|corp|intranet)' "$text"
  } | sort -t: -k1,1n -k2,2 -u
)

[ -z "$hits" ] && exit 0
printf '%s\n' "$hits" | sed "s|^|leak-check: $label:|" >&2
exit 1
