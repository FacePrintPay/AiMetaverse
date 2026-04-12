#!/data/data/com.termux/files/usr/bin/bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="$HOME/videocourts_scan_$TS.txt"
echo "[*] Starting VideoCourts scan..."
echo "[*] Output: $OUT"
echo
SEARCH_ROOTS="$HOME"
EXT_REGEX='\.(js|ts|jsx|tsx|py|rs|go|sh|html|htm|css|md|txt|json|yml|yaml|pdf)$'
> "$OUT"
find "$SEARCH_ROOTS" -type f 2>/dev/null | while read -r FILE; do
  # filter by extension
  if echo "$FILE" | grep -Eiq "$EXT_REGEX"; then
    # filename match
    if echo "$FILE" | grep -Eiq 'videocourts'; then
      echo "$FILE" | tee -a "$OUT"
      continue
    fi
    # content match (text only)
    if file "$FILE" | grep -qi text; then
      grep -Eiq 'videocourts' "$FILE" 2>/dev/null && \
        echo "$FILE" | tee -a "$OUT"
    fi
  fi
done
echo
echo "[✓] Scan complete"
echo "[✓] Found $(wc -l < "$OUT") files"
