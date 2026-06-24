#!/usr/bin/env bash
# install.sh — deploy context-doctor skill to ~/.claude/skills/context-doctor/
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/skills/context-doctor"
mkdir -p "$TARGET"
for item in SKILL.md README.md references; do
  [ -e "$REPO_ROOT/$item" ] || continue
  rm -rf "$TARGET/$item"
  cp -r "$REPO_ROOT/$item" "$TARGET/$item"
done
echo "deployed: $TARGET  (source: $REPO_ROOT)"
