#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid v2 - CODE CARVE FROM FULL STORAGE DUMP
# Extracts code/config/docs from:
#   ~/YesQuidExtracts/full_storage_dump
# into:
#   ~/YesQuidExtracts/code_recovery
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

SRC="$HOME/YesQuidExtracts/full_storage_dump"
DEST="$HOME/YesQuidExtracts/code_recovery"
FILTER="$HOME/yq_all_code_filter.txt"
LOG_DIR="$HOME/YesQuidLogs"

mkdir -p "$DEST" "$LOG_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/code_carve_$TS.log"

echo -e "${CYAN}================================================${RESET}"
echo -e "${CYAN} YesQuid CODE CARVE                            ${RESET}"
echo -e "${CYAN}================================================${RESET}"
echo -e "${YELLOW}Source : ${SRC}${RESET}"
echo -e "${YELLOW}Dest   : ${DEST}${RESET}"
echo -e "${YELLOW}Log    : ${LOG}${RESET}"
echo

if [ ! -d "$SRC" ]; then
  echo -e "${RED}[!] Source dump not found: $SRC${RESET}"
  echo "[!] Run full storage pull first." | tee -a "$LOG"
  exit 1
fi

if [ ! -f "$FILTER" ]; then
  echo -e "${RED}[!] Filter file missing: $FILTER${RESET}"
  echo "[!] Create yq_all_code_filter.txt first." | tee -a "$LOG"
  exit 1
fi

echo "[*] Starting code carve..." | tee -a "$LOG"

if command -v rsync >/dev/null 2>&1; then
  echo "[*] Using rsync with filter file..." | tee -a "$LOG"
  rsync -a \
    --include-from="$FILTER" \
    --exclude='*' \
    "$SRC"/ "$DEST"/ \
    | tee -a "$LOG"
else
  echo "[*] rsync not found, using find + cp --parents..." | tee -a "$LOG"
  find "$SRC" -type f \
    \( -iname "*.sh" -o -iname "*.bash" -o -iname "*.zsh" \
       -o -iname "*.py" -o -iname "*.ipynb" \
       -o -iname "*.js" -o -iname "*.jsx" \
       -o -iname "*.ts" -o -iname "*.tsx" \
       -o -iname "*.json" \
       -o -iname "*.yaml" -o -iname "*.yml" \
       -o -iname "*.toml" -o -iname "*.ini" -o -iname "*.cfg" -o -iname "*.env" \
       -o -iname "*.php" -o -iname "*.rb" -o -iname "*.go" -o -iname "*.rs" \
       -o -iname "*.java" -o -iname "*.kt" -o -iname "*.swift" \
       -o -iname "*.c" -o -iname "*.cpp" -o -iname "*.h" -o -iname "*.hpp" \
       -o -iname "*.sql" \
       -o -iname "*.html" -o -iname "*.htm" \
       -o -iname "*.css" -o -iname "*.scss" -o -iname "*.sass" -o -iname "*.less" \
       -o -iname "*.md" \
       -o -iname "Dockerfile" -o -iname "*.dockerfile" \
    \) -print0 \
    | xargs -0 -I{} cp --parents -v "{}" "$DEST" 2>&1 | tee -a "$LOG"
fi

echo >> "$LOG"
echo "[✓] Code carve complete." | tee -a "$LOG"

echo
echo -e "${GREEN}[✓] Done.${RESET}"
echo -e "${GREEN}[✓] Code bucket : ${DEST}${RESET}"
echo -e "${GREEN}[✓] Log         : ${LOG}${RESET}"
