#!/bin/sh
# Claude Code PreToolUse hook: refuses a Write or Edit that would put private information into this repo.
repo=$(cd "$(dirname "$0")/.." && pwd -P)
input=$(cat)

path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$path" ] || exit 0

# Skills are edited through ~/.claude/skills symlinks, so resolve the real directory first.
dir=$(dirname "$path")
while [ ! -d "$dir" ]; do dir=$(dirname "$dir"); done
real=$(cd "$dir" && pwd -P)
case "$real/" in
  "$repo"/*) ;;
  *) exit 0 ;;
esac

printf '%s' "$input" |
  jq -r '.tool_input | [.content, .new_string, (.edits // [] | .[].new_string)] | map(select(. != null)) | .[]' |
  "$repo/scripts/leak-check.sh" --label "$path" && exit 0

echo "Blocked: this would put private information into the public coding-skills repo. Use a placeholder, or move it to the project's private context file." >&2
exit 2
