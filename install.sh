#!/usr/bin/env bash
# install.sh — deploy claude-md-doctor skill to ~/.claude/skills/claude-md-doctor/
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/skills/claude-md-doctor"
mkdir -p "$TARGET"
for item in SKILL.md README.md references; do
  [ -e "$REPO_ROOT/$item" ] || continue
  rm -rf "$TARGET/$item"
  cp -r "$REPO_ROOT/$item" "$TARGET/$item"
done
echo "deployed: $TARGET  (source: $REPO_ROOT)"
