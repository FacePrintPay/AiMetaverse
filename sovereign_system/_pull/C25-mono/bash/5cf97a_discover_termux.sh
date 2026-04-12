#!/usr/bin/env bash
set -euo pipefail

source "$SYSROOT/core/roots.env"

OUT="$SYSROOT/results/discovery_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"

echo "Scanning Termux HOME..."
find "$HOME" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) > "$OUT/home_scripts.txt"

echo "Scanning shared storage..."
find "$SHARED" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) > "$OUT/shared_scripts.txt"

echo "Scanning Obsidian vaults..."
find "$OBSIDIAN" -type f > "$OUT/obsidian_files.txt"

wc -l "$OUT"/*.txt > "$OUT/counts.txt"
