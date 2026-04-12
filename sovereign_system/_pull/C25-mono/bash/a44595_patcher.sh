#!/data/data/com.termux/files/usr/bin/bash
BASE="$HOME/github-repos/Constillation25"
source "$BASE/_agents/claude_api.sh"
MANIFEST="$BASE/_build/manifest.json"
PATCH_DIR="$BASE/_patches"
LOG="$BASE/_logs/patcher.log"
mkdir -p "$PATCH_DIR"

echo "[PATCHER] $(date)" | tee "$LOG"

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: run pathfinder first"; exit 1
fi

TOTAL_FIXED=0

python3 -c "
import json
m=json.load(open('$MANIFEST'))
for repo,info in m['repos'].items():
    for ext in ['py','js','ts','java']:
        for f in info.get('files',[]):
            if f.endswith('.'+ext):
                print(repo+'|'+f)
" | while IFS='|' read -r REPO FILE; do
  FULL="$BASE/$REPO/$FILE"
  [ ! -f "$FULL" ] && continue
  EXT="${FILE##*.}"

  ERROR=""
  case "$EXT" in
    py)  ERROR=$(python3 -m py_compile "$FULL" 2>&1) ;;
    js)  command -v node &>/dev/null && ERROR=$(node --check "$FULL" 2>&1) ;;
    json) ERROR=$(python3 -m json.tool "$FULL" > /dev/null 2>&1 || python3 -m json.tool "$FULL" 2>&1) ;;
  esac

  if [ -n "$ERROR" ]; then
    LINES=$(wc -l < "$FULL" 2>/dev/null || echo 999)
    [ "$LINES" -gt 150 ] && echo "  SKIP (too large): $REPO/$FILE" >> "$LOG" && continue

    CONTENT=$(cat "$FULL")
    FIXED=$(claude "Fix this $EXT file. Return ONLY corrected raw code, no markdown, no explanation.

FILE: $FILE
ERROR: $ERROR

CODE:
$CONTENT")

    if [ -n "$FIXED" ] && ! echo "$FIXED" | grep -q "^ERR:"; then
      cp "$FULL" "${FULL}.bak"
      printf '%s\n' "$FIXED" > "$FULL"
      echo "  ✓ Fixed: $REPO/$FILE" | tee -a "$LOG"
    fi
  fi
done

echo "[PATCHER] Done" | tee -a "$LOG"
echo "✓ PATCHER complete"
