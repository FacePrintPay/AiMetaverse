#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME"
TARGET="consolidate_obsidian.sh"

echo "🔍 Searching for $TARGET under $ROOT ..."

FOUND="$(find "$ROOT" -type f -name "$TARGET" 2>/dev/null | head -n 1)"

if [[ -z "$FOUND" ]]; then
  echo "❌ ERROR: $TARGET not found anywhere under $ROOT"
  exit 1
fi

echo "✅ Found: $FOUND"

echo "🔧 Fixing permissions"
chmod +x "$FOUND" || true

echo "🧹 Fixing line endings (CRLF → LF if needed)"
sed -i 's/\r$//' "$FOUND" || true

echo "🚀 Executing script"
bash "$FOUND"

echo "✅ DONE"
