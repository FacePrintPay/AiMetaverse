#!/usr/bin/env bash
set -euo pipefail

LIST="$1"
TAG="$2"

OUTBASE="$SYSROOT/results/bulk_$TAG"
mkdir -p "$OUTBASE"

while IFS= read -r SCRIPT; do
  NAME=$(basename "$SCRIPT")
  SAFE=$(echo "$NAME" | tr '/' '_' )
  OUT="$OUTBASE/$SAFE"

  echo "▶ Running $SCRIPT"
  "$SYSROOT/core/wrap.sh" "$SCRIPT" "$OUT" || true
done < "$LIST"
