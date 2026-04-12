#!/usr/bin/env bash
set -e

STACK_DIR="$HOME/STACK/source"

echo "📦 Loading stacks from $STACK_DIR"

for f in "$STACK_DIR"/*.json; do
  echo "— Loaded $(basename "$f")"
done
