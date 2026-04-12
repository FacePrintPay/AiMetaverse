#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$1"
OUT="$2"

mkdir -p "$OUT"

if [[ ! -x "$SCRIPT" ]]; then
  chmod +x "$SCRIPT" || true
fi

bash "$SCRIPT" > "$OUT/stdout.txt" 2>&1
