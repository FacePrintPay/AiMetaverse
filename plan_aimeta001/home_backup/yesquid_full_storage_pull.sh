#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid v2 - FULL STORAGE PULL
# Pulls EVERYTHING from ~/storage into a local dump.
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

SRC="$HOME/storage"
DEST="$HOME/YesQuidExtracts/full_storage_dump"
LOG_DIR="$HOME/YesQuidLogs"

mkdir -p "$DEST" "$LOG_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/full_storage_pull_$TS.log"

echo -e "${CYAN}================================================${RESET}"
echo -e "${CYAN} YesQuid FULL STORAGE PULL                      ${RESET}"
echo -e "${CYAN}================================================${RESET}"
echo -e "${YELLOW}Source : ${SRC}${RESET}"
echo -e "${YELLOW}Dest   : ${DEST}${RESET}"
echo -e "${YELLOW}Log    : ${LOG}${RESET}"
echo

echo "[*] Starting full copy..." | tee -a "$LOG"

if command -v rsync >/dev/null 2>&1; then
  echo "[*] Using rsync -a ..." | tee -a "$LOG"
  rsync -a --info=stats1,progress2 "$SRC"/ "$DEST"/ | tee -a "$LOG"
else
  echo "[*] rsync not found, falling back to cp -a" | tee -a "$LOG"
  cp -a "$SRC"/. "$DEST"/ 2>&1 | tee -a "$LOG"
fi

echo >> "$LOG"
echo "[✓] Full storage pull complete." | tee -a "$LOG"

echo
echo -e "${GREEN}[✓] Done.${RESET}"
echo -e "${GREEN}[✓] Dump : ${DEST}${RESET}"
echo -e "${GREEN}[✓] Log  : ${LOG}${RESET}"
