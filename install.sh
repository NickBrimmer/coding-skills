#!/bin/sh
# Symlinks, not copies, so edits in the clone are live without a second step.
set -e

repo=$(cd "$(dirname "$0")" && pwd)
dest="${1:-$HOME/.claude/skills}"

mkdir -p "$dest"

for dir in "$repo"/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  skill=$(basename "$dir")
  if [ -e "$dest/$skill" ] && [ ! -L "$dest/$skill" ]; then
    echo "skip $skill: $dest/$skill exists and is not a symlink"
    continue
  fi
  [ "$(readlink "$dest/$skill")" = "$repo/$skill" ] && continue
  ln -sfn "$repo/$skill" "$dest/$skill"
  echo "linked $skill -> $repo/$skill"
done

for link in "$dest"/*; do
  [ -L "$link" ] && [ ! -e "$link" ] || continue
  case $(readlink "$link") in
    "$repo"/*) echo "remove: $link points to a skill folder that is gone" ;;
  esac
done

git -C "$repo" config core.hooksPath .githooks
echo "leak check on: commit and push hooks in .githooks/"

denylist="$HOME/.config/coding-skills/denylist.txt"
[ -s "$denylist" ] || echo "warning: no $denylist yet; commits and pushes are blocked until it exists (README, Privacy)"
[ ! -s "$denylist" ] || grep -qx '# full list' "$denylist" || echo "warning: $denylist has no '# full list' line; merge in the full list, then add that line"
