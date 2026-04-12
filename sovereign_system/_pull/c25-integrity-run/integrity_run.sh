#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
TS="$(date +%Y%m%d_%H%M%S)"
REPORT_DIR="$ROOT/reports"
ART_DIR="$ROOT/artifacts"
mkdir -p "$REPORT_DIR" "$ART_DIR"
# Output files
FILELIST="$REPORT_DIR/integrity_filelist_${TS}.txt"
MANIFEST="$REPORT_DIR/integrity_manifest_${TS}.sha256"
SUMMARY="$REPORT_DIR/integrity_summary_${TS}.txt"
BUNDLE="$ART_DIR/integrity_bundle_${TS}.tar.gz"
# What to include/exclude (tweak if you need broader evidence dirs)
EXCLUDES=(
  "./.git"
  "./node_modules"
  "./.next"
  "./dist"
  "./build"
  "./artifacts"
  "./reports"
)
# Build find prune expression
PRUNE_EXPR=()
for ex in "${EXCLUDES[@]}"; do
  PRUNE_EXPR+=( -path "$ex" -o -path "${ex}/*" -o )
done
# drop trailing -o
unset 'PRUNE_EXPR[${#PRUNE_EXPR[@]}-1]'
echo "[*] Integrity run @ $TS"
echo "[*] Root: $ROOT"
# 1) Deterministic file list (sorted)
echo "[*] Building file list..."
# shellcheck disable=SC2016
find . \
  \( "${PRUNE_EXPR[@]}" \) -prune -o \
  -type f -print0 \
| sort -z \
| while IFS= read -r -d '' f; do
    # size + path (stable)
    sz="$(wc -c < "$f" 2>/dev/null || echo 0)"
    printf "%s\t%s\n" "$sz" "$f"
  done > "$FILELIST"
# 2) Hash manifest (SHA-256) based on the sorted list above
echo "[*] Hashing (sha256)... this is the heavy step."
cut -f2- "$FILELIST" | while IFS= read -r f; do
  sha256sum "$f"
done > "$MANIFEST"
# 3) Summary
echo "[*] Writing summary..."
COUNT="$(wc -l < "$FILELIST" | tr -d ' ')"
TOTAL_BYTES="$(awk -F'\t' '{s+=$1} END{printf "%.0f", s}' "$FILELIST" 2>/dev/null || echo 0)"
{
  echo "INTEGRITY RUN SUMMARY"
  echo "Timestamp: $TS"
  echo "Root: $ROOT"
  echo "Files hashed: $COUNT"
  echo "Total bytes: $TOTAL_BYTES"
  echo
  echo "Outputs:"
  echo "  Filelist : $FILELIST"
  echo "  Manifest : $MANIFEST"
} > "$SUMMARY"
# 4) Bundle outputs (manifest + summary + filelist)
echo "[*] Packaging artifacts..."
tar -czf "$BUNDLE" \
  "$(basename "$FILELIST")" \
  "$(basename "$MANIFEST")" \
  "$(basename "$SUMMARY")" \
  -C "$REPORT_DIR" .
# That tar line above may include extra if run from wrong CWD; safer explicit:
rm -f "$BUNDLE"
tar -czf "$BUNDLE" -C "$REPORT_DIR" \
  "$(basename "$FILELIST")" \
  "$(basename "$MANIFEST")" \
  "$(basename "$SUMMARY")"
echo "✅ Integrity complete"
echo "   $SUMMARY"
echo "   $MANIFEST"
echo "   $BUNDLE"
