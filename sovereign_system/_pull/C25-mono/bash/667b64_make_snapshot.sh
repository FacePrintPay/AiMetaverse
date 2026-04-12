#!/data/data/com.termux/files/usr/bin/bash
BASE="$HOME/TotalRecall/complaint_project"
OUT="$BASE/final_output"
STAMP=$(date +"%Y%m%d_%H%M%S")
TXT="$OUT/complaint_snapshot_${STAMP}.txt"

mkdir -p "$OUT"

echo "📚 creating $TXT …"

{
  echo "TOTAL RECALL – FULL COMPLAINT SNAPSHOT"
  echo "Generated: $(date -Iseconds)"
  echo
  echo "── FILE INDEX ──"
  find "$BASE" -type f | sort
  echo
  echo "── SHA256 HASHES ──"
  find "$BASE" -type f -exec sha256sum {} \;
  echo
  echo "── TEXT CONTENT ──"
  cat "$BASE"/FINAL_PACKAGE/*.txt 2>/dev/null || echo "(no text files found)"
} > "$TXT"

echo "✅ text snapshot built at: $TXT"
