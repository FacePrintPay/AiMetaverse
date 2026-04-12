#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/monorepo"
INBOX="$ROOT/inbox/shared_links"
OUT="$ROOT/out/extracted"
PROV="$ROOT/docs/provenance"

echo "[MARS] 🌾 Sharecrop ingest starting"

mkdir -p "$INBOX/html" "$INBOX/pdfs" "$OUT" "$PROV"

URLS_FILE="$INBOX/urls.txt"
if [[ -f "$URLS_FILE" ]]; then
  echo "[MARS] Fetching share links from $URLS_FILE"
  while read -r url; do
    [[ -z "${url// }" ]] && continue
    fname="$(printf "%s" "$url" | sha256sum | awk '{print $1}' | cut -c1-12).html"
    curl -LsS "$url" -o "$INBOX/html/$fname"
  done < "$URLS_FILE"
fi

if compgen -G "$INBOX/html/*.html" > /dev/null; then
  echo "[MARS] Carving HTML"
  python3 "$ROOT/tools/carve/carve_shared_html.py"
fi

if compgen -G "$INBOX/pdfs/*.pdf" > /dev/null; then
  echo "[MARS] Carving PDFs"
  python3 "$ROOT/tools/carve/carve_pdfs.py"
fi

echo "[MARS] Writing inventory"
find "$OUT" -type f -exec sha256sum {} + > "$PROV/mars_sharecrop_inventory_$(date +%Y%m%d_%H%M%S).txt"

echo "[MARS] ✅ Sharecrop ingest complete"
