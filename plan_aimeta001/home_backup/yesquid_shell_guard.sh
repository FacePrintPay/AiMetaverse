#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# YesQuid Shell Guard v1
# "If it runs, it runs clean. If it fails, it explains."
# ======================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

LOG_ROOT="$HOME/YesQuidLogs"
mkdir -p "$LOG_ROOT"

if [ $# -lt 1 ]; then
  echo -e "${RED}[YesQuidGuard] Error:${RESET} No script provided."
  echo -e "${YELLOW}Usage:${RESET} yq <script.sh> [args...]"
  exit 1
fi

SCRIPT="$1"
shift || true

if [ ! -f "$SCRIPT" ]; then
  echo -e "${RED}[YesQuidGuard] Error:${RESET} Script not found: $SCRIPT"
  exit 1
fi

if [ ! -s "$SCRIPT" ]; then
  echo -e "${RED}[YesQuidGuard] Error:${RESET} Script is empty: $SCRIPT"
  exit 1
fi

TS="$(date +%Y%m%d_%H%M%S)"
BASENAME="$(basename "$SCRIPT")"
RUN_LOG="$LOG_ROOT/run_${BASENAME}_${TS}.log"

echo -e "${CYAN}[YesQuidGuard]================================================${RESET}"
echo -e "${CYAN} Script :${RESET} $SCRIPT"
echo -e "${CYAN} Time   :${RESET} $TS"
echo -e "${CYAN} Log    :${RESET} $RUN_LOG"
echo -e "${CYAN}========================================================${RESET}"

echo -e "${YELLOW}[*] Running bash -n syntax check...${RESET}"
if bash -n "$SCRIPT" 2>>"$RUN_LOG"; then
  echo -e "${GREEN}[✓] Syntax check passed.${RESET}"
else
  echo -e "${RED}[✗] Syntax check FAILED. See log:${RESET} $RUN_LOG"
  exit 2
fi

echo -e "${YELLOW}[*] Preview (first 10 lines)...${RESET}"
head -n 10 "$SCRIPT" | sed 's/^/    /'

echo -e "${YELLOW}[*] Executing script under guard...${RESET}"
{
  echo "===== YesQuidGuard Run @ $TS ====="
  echo "SCRIPT: $SCRIPT"
  echo "ARGS:   $*"
  echo "----------------------------------"
} >>"$RUN_LOG"

if bash "$SCRIPT" "$@" >>"$RUN_LOG" 2>&1; then
  echo -e "${GREEN}[✓] Script completed successfully.${RESET}"
  echo -e "${GREEN}[✓] Full log:${RESET} $RUN_LOG"
  exit 0
else
  RC=$?
  echo -e "${RED}[✗] Script exited with code $RC.${RESET}"
  echo -e "${YELLOW}    See:${RESET} $RUN_LOG"
  exit "$RC"
fi
