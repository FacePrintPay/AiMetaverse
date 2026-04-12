#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/monorepo"
INP="$ROOT/inbox/shared_links/pdfs"
TXT="$ROOT/out/quarantine/pdf_text"
OUT="$ROOT/out/extracted"
PROV="$ROOT/docs/provenance"

mkdir -p "$TXT" "$OUT" "$PROV"

ts="$(date +%Y%m%d_%H%M%S)"
prov="$PROV/pdf_poppler_carve_${ts}.txt"

echo "[MARS] PDF->TXT via pdftotext" | tee "$prov"

shopt -s nullglob
for pdf in "$INP"/*.pdf; do
  base="$(basename "$pdf" .pdf)"
  out_txt="$TXT/${base}.txt"
  echo "[+] $pdf -> $out_txt" | tee -a "$prov"
  pdftotext -layout "$pdf" "$out_txt"
done

echo "[✓] Done. Text files in: $TXT" | tee -a "$prov"
