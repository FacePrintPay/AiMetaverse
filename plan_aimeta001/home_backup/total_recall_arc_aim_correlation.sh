#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

OUT="$HOME/TOTAL_RECALL_ARC_AIM_CORRELATION.txt"

SRC_DIRS=(
  "$HOME/totalrecall"
  "$HOME/total_recall_runs"
  "$HOME/totalrecall_output"
  "$HOME/storage/shared"
)

# -------------------------------
# INIT
# -------------------------------
echo "TOTAL RECALL — ARC / AIM TEMPORAL CORRELATION REPORT" > "$OUT"
echo "Generated: $(date -Iseconds)" >> "$OUT"
echo "Host: $(hostname 2>/dev/null || echo Termux)" >> "$OUT"
echo "--------------------------------------------------" >> "$OUT"
echo "" >> "$OUT"

# -------------------------------
# FUNCTION: SCAN
# -------------------------------
scan_term() {
  local LABEL="$1"
  local REGEX="$2"

  echo "## $LABEL" >> "$OUT"
  echo "" >> "$OUT"

  local FOUND=0

  for DIR in "${SRC_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
      MATCHES=$(find "$DIR" -type f 2>/dev/null | grep -Ei "$REGEX" || true)

      if [ -n "$MATCHES" ]; then
        FOUND=1
        echo "Source: $DIR" >> "$OUT"
        while read -r FILE; do
          TS=$(stat -c '%y' "$FILE" 2>/dev/null || echo "unknown")
          echo "$TS  $FILE" >> "$OUT"
        done <<< "$MATCHES"
        echo "" >> "$OUT"
      fi
    fi
  done

  if [ "$FOUND" -eq 0 ]; then
    echo "⚠ No artifacts found for pattern: $REGEX" >> "$OUT"
    echo "" >> "$OUT"
  fi
}

# -------------------------------
# SCANS (SEPARATED SIGNALS)
# -------------------------------
scan_term "Total Recall Artifacts" "total[_-]?recall"
scan_term "ARC / ARCAI Artifacts" "arc[_-]?ai|\\barc\\b"
scan_term "AIM Artifacts (NOT AIME)" "\\baim\\b"
scan_term "Secondary AI References" "\\bai\\b"

# -------------------------------
# NOTES
# -------------------------------
echo "## Notes" >> "$OUT"
echo "- All findings are filesystem-backed." >> "$OUT"
echo "- Correlation is temporal only." >> "$OUT"
echo "- No execution, monitoring, or ingestion is asserted." >> "$OUT"
echo "- AIM and ARC are treated as independent signals." >> "$OUT"
echo "" >> "$OUT"

echo "END OF REPORT" >> "$OUT"

# -------------------------------
# OUTPUT
# -------------------------------
echo ""
echo "✔ DONE"
echo "Report written to:"
echo "$OUT"


