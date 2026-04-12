#!/data/data/com.termux/files/usr/bin/bash
# ================================================
# YesQuid v2 - CODE CARVE (HARDLOCK)
# Pull every code-ish file from full_storage_dump
# into code_recovery with parents preserved.
# ================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

SOURCE="$HOME/YesQuidExtracts/full_storage_dump"
DEST="$HOME/YesQuidExtracts/code_recovery"
LOG_DIR="$HOME/YesQuidLogs"
TS="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/code_carve_$TS.log"

mkdir -p "$DEST" "$LOG_DIR"

{
  echo -e "${CYAN}================================================${RESET}"
  echo -e "${CYAN} YesQuid CODE CARVE v2                          ${RESET}"
  echo -e "${CYAN}================================================${RESET}"
  echo "Source : $SOURCE"
  echo "Dest   : $DEST"
  echo "Log    : $LOG"
  echo

  if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}[!] SOURCE missing: $SOURCE${RESET}"
    exit 1
  fi

  echo -e "${YELLOW}[*] Starting code carve (find + cp --parents)...${RESET}"

  find "$SOURCE" -type f \
    \( -iname "*.sh"   -o -iname "*.bash"  -o -iname "*.zsh"    \
       -iname "*.py"   -o -iname "*.ipynb"                       \
       -iname "*.js"   -o -iname "*.jsx"  -o -iname "*.ts"      \
       -iname "*.tsx"                                         \
       -iname "*.json" -o -iname "*.yaml" -o -iname "*.yml"    \
       -iname "*.toml" -o -iname "*.ini"  -o -iname "*.cfg"    \
       -iname "*.env"                                          \
       -iname "*.php"  -o -iname "*.rb"   -o -iname "*.go"     \
       -iname "*.rs"   -o -iname "*.java" -o -iname "*.kt"     \
       -iname "*.swift"                                        \
       -iname "*.c"    -o -iname "*.cpp"  -o -iname "*.h"      \
       -iname "*.hpp"                                          \
       -iname "*.sql"                                          \
       -iname "*.html" -o -iname "*.htm"                       \
       -iname "*.css"  -o -iname "*.scss" -o -iname "*.sass"   \
       -iname "*.less"                                         \
       -iname "*.md"                                           \
       -iname "Dockerfile" -o -iname "*.dockerfile"            \
    \) \
    -print -exec cp --parents "{}" "$DEST" \;

  echo
  COUNT="$(find "$DEST" -type f | wc -l || echo 0)"
  echo -e "${GREEN}[✓] Code carve complete.${RESET}"
  echo -e "${GREEN}[✓] Files in code_recovery: ${COUNT}${RESET}"

  if [ "$COUNT" -eq 0 ]; then
    echo -e "${RED}[!] WARNING: No files found. Something is off.${RESET}"
    exit 2
  fi

} 2>&1 | tee -a "$LOG"
