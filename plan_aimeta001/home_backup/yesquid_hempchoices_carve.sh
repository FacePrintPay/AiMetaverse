#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid - HEMPC HOICES / SOVEREIGN_VAULT CODE CARVE
# Pull every code-ish file from:
#   ~/YesQuidExtracts/gdrive_SovereignVault
# into:
#   ~/YesQuidExtracts/hempchoices_stage/code_recovery
# with parent directories preserved.
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

SRC="$HOME/YesQuidExtracts/gdrive_SovereignVault"
DEST="$HOME/YesQuidExtracts/hempchoices_stage/code_recovery"
LOG_DIR="$HOME/YesQuidLogs"
TS="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/hempchoices_code_carve_$TS.log"

mkdir -p "$DEST" "$LOG_DIR"

{
  echo -e "${CYAN}================================================${RESET}"
  echo -e "${CYAN} YesQuid HEMPC HOICES CODE CARVE                ${RESET}"
  echo -e "${CYAN}================================================${RESET}"
  echo "Source : $SRC"
  echo "Dest   : $DEST"
  echo "Log    : $LOG"
  echo

  if [ ! -d "$SRC" ]; then
    echo -e "${RED}[!] Source dir does NOT exist: $SRC${RESET}"
    exit 0
  fi

  echo -e "${YELLOW}[*] Scanning for code-like files...${RESET}"

  # Build list with find + explicit extension filter
  TMP_LIST="$(mktemp)"
  find "$SRC" -type f \( \
      -name '*.sh'    -o -name '*.bash'  -o -name '*.zsh'    -o \
      -name '*.py'    -o -name '*.ipynb'                     -o \
      -name '*.js'    -o -name '*.jsx'   -o -name '*.ts'     -o \
      -name '*.tsx'   -o -name '*.json'  -o -name '*.yaml'   -o \
      -name '*.yml'   -o -name '*.toml'  -o -name '*.ini'    -o \
      -name '*.cfg'   -o -name '*.env'   -o -name '*.php'    -o \
      -name '*.rb'    -o -name '*.go'    -o -name '*.rs'     -o \
      -name '*.java'  -o -name '*.kt'    -o -name '*.swift'  -o \
      -name '*.c'     -o -name '*.cpp'   -o -name '*.h'      -o \
      -name '*.hpp'   -o -name '*.sql'   -o -name '*.html'   -o \
      -name '*.htm'   -o -name '*.css'   -o -name '*.scss'   -o \
      -name '*.sass'  -o -name '*.less'  -o -name '*.md'     -o \
      -name 'Dockerfile' -o -name '*.dockerfile' \
    \) 2>/dev/null | sort > "$TMP_LIST"

  FILE_COUNT=$(wc -l < "$TMP_LIST" 2>/dev/null || echo 0)
  echo -e "${GREEN}[+] Files matched: $FILE_COUNT${RESET}"
  echo

  if [ "$FILE_COUNT" -eq 0 ]; then
    echo -e "${RED}[!] WARNING: No code-ish files found under $SRC${RESET}"
    rm -f "$TMP_LIST"
    exit 0
  fi

  echo -e "${YELLOW}[*] Copying files with parents preserved...${RESET}"

  while IFS= read -r src_path; do
    [ -z "$src_path" ] && continue
    rel="${src_path#$SRC/}"
    dest_dir="$DEST/$(dirname "$rel")"
    mkdir -p "$dest_dir"
    cp -a "$src_path" "$dest_dir/" 2>>"$LOG" || \
      echo "[WARN] Failed to copy: $src_path" >> "$LOG"
  done < "$TMP_LIST"

  rm -f "$TMP_LIST"

  FINAL_COUNT=$(find "$DEST" -type f | wc -l 2>/dev/null || echo 0)
  echo
  echo -e "${GREEN}[✓] Code carve complete.${RESET}"
  echo -e "${GREEN}[✓] Files in code_recovery: $FINAL_COUNT${RESET}"
  echo -e "${CYAN}[✓] Code bucket : $DEST${RESET}"

} 2>&1 | tee -a "$LOG"
