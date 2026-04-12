#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# HEMPCHOICES REBUILD - PASS 1 (CODE RECOVERY)
# ==========================================================
# Goal: from hempchoices@gmail export (gdrive_SovereignVault),
# pull out ALL code-ish files from:
#   - SOVEREIGN_VAULT
#   - Z-34, Z-35, Z-36
#   - Z-36_Bundle.tar.gz, src_*.tar.gz, Dev*.tar.gz,
#     *github.com*.tar.gz, modules_*.tar.gz
#   - Obsidian (in case there are bashes/snippets)
#
# Result:
#   ~/YesQuidExtracts/hempchoices_stage/
#       README_rebuild.txt
#       raw_tar_contents/   # exploded tarballs
#       code_recovery/      # all code files with parents
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

SRC_ROOT="${1:-$HOME/YesQuidExtracts/gdrive_SovereignVault}"
STAGE_BASE="$HOME/YesQuidExtracts/hempchoices_stage"
RAW_TAR="$STAGE_BASE/raw_tar_contents"
CODE_OUT="$STAGE_BASE/code_recovery"
LOG_DIR="$HOME/YesQuidLogs"
TS="$(date +%Y%m%d_%H%M%S)"
LOG="$LOG_DIR/hempchoices_rebuild_pass1_$TS.log"

mkdir -p "$STAGE_BASE" "$RAW_TAR" "$CODE_OUT" "$LOG_DIR"

{
  echo "================================================"
  echo " HEMPCHOICES REBUILD - PASS 1 (CODE RECOVERY)"
  echo "================================================"
  echo
  echo "Source root : $SRC_ROOT"
  echo "Stage base  : $STAGE_BASE"
  echo "Log         : $LOG"
  echo

  if [ ! -d "$SRC_ROOT" ]; then
    echo "[!] Source root does not exist: $SRC_ROOT"
    exit 1
  fi

  echo "[*] Sanity check: listing top-level of source..."
  ls -la "$SRC_ROOT" || true
  echo

  # --------------------------------------------------
  # 1) README for THIS PASS (dev rebuild context)
  # --------------------------------------------------
  README="$STAGE_BASE/README_rebuild.txt"
  cat > "$README" << README_EOF
HEMPCHOICES REBUILD - PASS 1 (CODE RECOVERY)
============================================

This stage is for DEVELOPMENT REBUILD, not legal packaging.

Source:
  $SRC_ROOT
  (hempchoices@gmail SovereignVault / Z-series export)

What this stage does:
  - Explodes dev-related tarballs from the hempchoices export
    into: raw_tar_contents/
  - Walks:
      - SOVEREIGN_VAULT/
      - Z-34/
      - Z-35/
      - Z-36/
      - Obsidian/
      - raw_tar_contents/
    and copies ALL code-ish files (js, ts, py, sh, html, css, etc.)
    into: code_recovery/ (with parent paths preserved).

This is your hunting ground for:
  - Next.js / React apps (package.json, next.config.mjs, etc.)
  - Node backends
  - Bash automation
  - Any other repos that lived under hempchoices.

Next steps after this script:
  - cd into code_recovery/
  - find package.json, next.config.*, pnpm-lock.yaml, etc.
  - rebuild Ai-Kre8tive / Stargate / other stacks from there.

README_EOF

  echo "[✓] Wrote rebuild README: $README"
  echo

  # --------------------------------------------------
  # 2) Explode tarballs that likely contain code
  # --------------------------------------------------
  echo "[*] Extracting dev-related tarballs from $SRC_ROOT ..."
  cd "$SRC_ROOT"

  # patterns we care about for code-bearing tarballs
  TARBALLS=()
  while IFS= read -r f; do TARBALLS+=("$f"); done < <(
    ls Dev*.tar.gz src_*.tar.gz *git-*_*.tar.gz modules_*.tar.gz Z-36_Bundle.tar.gz 2>/dev/null || true
  )

  if [ "${#TARBALLS[@]}" -eq 0 ]; then
    echo "[!] No matching dev tarballs found. Skipping tar extraction."
  else
    for f in "${TARBALLS[@]}"; do
      if [ ! -f "$f" ]; then
        continue
      fi
      SUBDIR="${f%.tar.gz}"
      DEST_DIR="$RAW_TAR/$SUBDIR"
      mkdir -p "$DEST_DIR"
      echo "[*]   -> extracting $f into $DEST_DIR"
      tar -xzf "$f" -C "$DEST_DIR"
    done
    echo "[✓] Tarball extraction complete."
  fi

  echo
  echo "[*] Snapshot of raw_tar_contents:"
  find "$RAW_TAR" -maxdepth 3 -type d | head -40
  echo

  # --------------------------------------------------
  # 3) CODE CARVE from key roots
  # --------------------------------------------------
  echo "[*] Starting code carve from hempchoices structures..."

  # Candidate roots to mine for code
  ROOTS=(
    "$SRC_ROOT/SOVEREIGN_VAULT"
    "$SRC_ROOT/Z-34"
    "$SRC_ROOT/Z-35"
    "$SRC_ROOT/Z-36"
    "$SRC_ROOT/Obsidian"
    "$RAW_TAR"
  )

  FILES_FOUND=0

  for R in "${ROOTS[@]}"; do
    if [ ! -d "$R" ]; then
      echo "[-] Skip (not present): $R"
      continue
    fi

    echo "[*] Mining code from: $R"

    # Big find with code-ish extensions
    find "$R" -type f \( \
        -iname "*.sh" -o \
        -iname "*.bash" -o \
        -iname "*.zsh" -o \
        -iname "*.py" -o \
        -iname "*.ipynb" -o \
        -iname "*.js" -o \
        -iname "*.jsx" -o \
        -iname "*.ts" -o \
        -iname "*.tsx" -o \
        -iname "*.json" -o \
        -iname "*.yaml" -o \
        -iname "*.yml" -o \
        -iname "*.toml" -o \
        -iname "*.ini" -o \
        -iname "*.cfg" -o \
        -iname "*.env" -o \
        -iname "*.php" -o \
        -iname "*.rb" -o \
        -iname "*.go" -o \
        -iname "*.rs" -o \
        -iname "*.java" -o \
        -iname "*.kt" -o \
        -iname "*.swift" -o \
        -iname "*.c" -o \
        -iname "*.cpp" -o \
        -iname "*.h" -o \
        -iname "*.hpp" -o \
        -iname "*.sql" -o \
        -iname "*.html" -o \
        -iname "*.htm" -o \
        -iname "*.css" -o \
        -iname "*.scss" -o \
        -iname "*.sass" -o \
        -iname "*.less" -o \
        -iname "*.md" \
      \) -print0 2>/dev/null | \
      while IFS= read -r -d '' f; do
        FILES_FOUND=$((FILES_FOUND + 1))
        # Preserve parent dirs relative to filesystem root
        # so we know original context
        cp --parents -nv "$f" "$CODE_OUT" >/dev/null 2>&1 || true
      done

  done

  echo
  echo "[*] Code carve finished."
  echo "[*] Files encountered (may include duplicates): $FILES_FOUND"

  # Count unique files in code_recovery
  if [ -d "$CODE_OUT" ]; then
    UNIQUE_COUNT=$(find "$CODE_OUT" -type f | wc -l | tr -d ' ')
  else
    UNIQUE_COUNT=0
  fi

  echo "[✓] Unique files in code_recovery: $UNIQUE_COUNT"
  echo
  echo "[*] Quick peek into code_recovery:"
  find "$CODE_OUT" -maxdepth 5 -type f | head -40
  echo

  if [ "$UNIQUE_COUNT" -eq 0 ]; then
    echo "[!] WARNING: code_recovery is empty. That means:"
    echo "    - Either the patterns missed extensions, or"
    echo "    - The source snapshot isn't where we think it is."
    echo "    Double-check: $SRC_ROOT and that SOVEREIGN_VAULT/Z-* exist."
  else
    echo "[✓] PASS 1 SUCCESS: You now have a concentrated code workspace at:"
    echo "    $CODE_OUT"
  fi

} | tee "$LOG"

echo
echo -e "${GREEN}[DONE] HEMPCHOICES REBUILD PASS 1 COMPLETE${RESET}"
echo -e "${GREEN}Stage dir :${RESET} $STAGE_BASE"
echo -e "${GREEN}Log       :${RESET} $LOG"
