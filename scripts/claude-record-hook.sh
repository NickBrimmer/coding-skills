#!/bin/sh
# Claude Code hook: nudges the agent to write to the branch's planning or review file as it works.
# Usage: claude-record-hook.sh posttool | stop | compact   (see README, "Record as you go")
# Silent unless the current branch has a planning or review file in the private folder.
event=$1
every=${RECORD_HOOK_EVERY:-15}
input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // "none"')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0

top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git branch --show-current 2>/dev/null)
key=$(printf '%s' "$branch" | grep -oE '^[A-Za-z]+-[0-9]+')
[ -n "$key" ] || exit 0

base="${PLANNING_FILES_DIR:-$HOME/Developer/planning-files}/$(basename "$top")"
found=$(find "$base/plans" "$base/reviews" -maxdepth 1 -iname "*$key*.md" 2>/dev/null)
[ -n "$found" ] || exit 0
plan=$(ls -t $found | head -1)

state="${TMPDIR:-/tmp}/claude-record-hook-$session"
count=$(cat "$state" 2>/dev/null || echo 0)

case "$event" in
  posttool)
    written=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    if [ "$written" = "$plan" ]; then echo 0 > "$state"; exit 0; fi
    count=$((count + 1)); echo "$count" > "$state"
    [ $((count % every)) -eq 0 ] || exit 0
    jq -n --arg m "$count tool calls since $plan was last written. Record any finding, finished step, or answer there now, tersely (plan-structure.md, Record as you go)." \
      '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
    ;;
  stop)
    active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
    blocked="$state.blocked"
    # Block once per stretch of unrecorded work, then let the turn end.
    if [ "$active" = "true" ] || [ -e "$blocked" ] || [ "$count" -lt 5 ]; then
      rm -f "$blocked"; echo 0 > "$state"; exit 0
    fi
    touch "$blocked"
    jq -n --arg r "This turn ran $count tool calls without writing $plan. Before replying, record what it found or finished there, or reply if nothing changed the plan." \
      '{decision: "block", reason: $r}'
    ;;
  compact)
    echo "Context was just compacted. Read the ## Status block of $plan before continuing; it is the source of truth, not the summary."
    ;;
esac
exit 0
