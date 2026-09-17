#!/bin/sh
# Symlinks, not copies, so edits in the clone are live without a second step.
set -e

repo=$(cd "$(dirname "$0")" && pwd)
dest="${1:-$HOME/.claude/skills}"

mkdir -p "$dest"

for skill in bug-hunt code-review ticket-planning; do
  if [ -e "$dest/$skill" ] && [ ! -L "$dest/$skill" ]; then
    echo "skip $skill: $dest/$skill exists and is not a symlink"
    continue
  fi
  ln -sfn "$repo/$skill" "$dest/$skill"
  echo "linked $skill -> $repo/$skill"
done
