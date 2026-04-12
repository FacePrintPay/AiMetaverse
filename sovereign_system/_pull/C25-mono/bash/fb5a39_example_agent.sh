#!/usr/bin/env bash
set -euo pipefail

OUT="$1"
mkdir -p "$OUT"

echo "Example agent ran at $(date)" > "$OUT/output.txt"
