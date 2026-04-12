#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid v2 - Immutable Core Guard (Minimal Stable Build)
# "If it ran clean once, it stays that way."
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

HOME_ROOT="$HOME"
IMMU_DIR="$HOME_ROOT/YesQuidImmutable"
GOLDEN_DIR="$IMMU_DIR/golden"
MANIFEST="$IMMU_DIR/manifest.txt"
LOG_FILE="$IMMU_DIR/immutable.log"

mkdir -p "$GOLDEN_DIR"

log() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') :: $1" >> "$LOG_FILE"
}

header() {
  echo -e "${CYAN}================================================${RESET}"
  echo -e "${CYAN} YesQuid Immutable Core Guard                   ${RESET}"
  echo -e "${CYAN}================================================${RESET}"
}

# Return list of protected files that actually exist
get_protected_files() {
  local files=()

  [ -f "$HOME_ROOT/.bashrc" ] && files+=("$HOME_ROOT/.bashrc")
  [ -f "$HOME_ROOT/.nanorc" ] && files+=("$HOME_ROOT/.nanorc")
  [ -f "$HOME_ROOT/yesquid_shell_guard.sh" ] && files+=("$HOME_ROOT/yesquid_shell_guard.sh")
  [ -f "$HOME_ROOT/pathos.sh" ] && files+=("$HOME_ROOT/pathos.sh")
  [ -f "$HOME_ROOT/PATHOS_OS/pathos/run.py" ] && files+=("$HOME_ROOT/PATHOS_OS/pathos/run.py")
  [ -f "$HOME_ROOT/SOVEREIGN_GTP/core/protocol.sh" ] && files+=("$HOME_ROOT/SOVEREIGN_GTP/core/protocol.sh")
  [ -f "$HOME_ROOT/SOVEREIGN_GTP/core/restore.sh" ] && files+=("$HOME_ROOT/SOVEREIGN_GTP/core/restore.sh")

  printf '%s\n' "${files[@]}"
}

rel_path() {
  local full="$1"
  echo "${full#"$HOME_ROOT/"}"
}

init_immutable() {
  header
  echo -e "${YELLOW}[INIT] Capturing golden state...${RESET}"
  mkdir -p "$IMMU_DIR"
  : > "$MANIFEST"

  local files
  mapfile -t files < <(get_protected_files)

  if [ "${#files[@]}" -eq 0 ]; then
    echo -e "${RED}[!] No protected files found to snapshot.${RESET}"
    log "[INIT] No protected files found."
    exit 1
  fi

  for f in "${files[@]}"; do
    local rel
    rel="$(rel_path "$f")"
    local target_dir="$GOLDEN_DIR/$(dirname "$rel")"

    mkdir -p "$target_dir"
    cp "$f" "$GOLDEN_DIR/$rel"

    (cd "$HOME_ROOT" && sha256sum "$rel") >> "$MANIFEST"

    echo -e "${GREEN}[+] Snapshotted:${RESET} $rel"
    log "[INIT] Snapshotted $rel"
  done

  echo -e "${GREEN}[✓] Golden state captured.${RESET}"
  echo -e "${GREEN}[✓] Manifest:${RESET} $MANIFEST"
  log "[INIT] Golden state captured."
}

check_immutable() {
  header
  echo -e "${YELLOW}[CHECK] Verifying protected files...${RESET}"

  if [ ! -f "$MANIFEST" ]; then
    echo -e "${RED}[!] No manifest found. Run: $0 init${RESET}"
    log "[CHECK] Manifest missing."
    exit 1
  fi

  local changes=0

  while read -r hash rel; do
    [ -z "$hash" ] && continue
    [ -z "$rel" ] && continue

    local live_path="$HOME_ROOT/$rel"
    local golden_path="$GOLDEN_DIR/$rel"

    # Golden exists, live missing → restore
    if [ ! -f "$live_path" ] && [ -f "$golden_path" ]; then
      mkdir -p "$(dirname "$live_path")"
      cp "$golden_path" "$live_path"
      echo -e "${RED}[RESTORE] Missing file restored:${RESET} $rel"
      log "[RESTORE] $rel was missing; restored."
      changes=$((changes + 1))
      continue
    fi

    # If either missing, skip
    if [ ! -f "$live_path" ] || [ ! -f "$golden_path" ]; then
      echo -e "${YELLOW}[SKIP] Incomplete pair for:${RESET} $rel"
      log "[SKIP] Incomplete pair: $rel"
      continue
    fi

    local current_hash
    current_hash="$(cd "$HOME_ROOT" && sha256sum "$rel" | awk '{print $1}')"

    if [ "$current_hash" != "$hash" ]; then
      echo -e "${RED}[MODIFIED] Drift detected:${RESET} $rel"
      log "[DRIFT] $rel modified. Restoring."
      cp "$golden_path" "$live_path"
      echo -e "${GREEN}[RESTORED] Reverted to golden:${RESET} $rel"
      log "[RESTORE] $rel restored."
      changes=$((changes + 1))
    else
      echo -e "${GREEN}[OK]${RESET} $rel"
    fi
  done < "$MANIFEST"

  if [ "$changes" -eq 0 ]; then
    echo -e "${GREEN}[✓] All protected files match golden state.${RESET}"
    log "[CHECK] All files clean."
  else
    echo -e "${YELLOW}[!] Drift corrected for $changes file(s).${RESET}"
    log "[CHECK] Drift corrected for $changes files."
  fi
}

cmd="${1:-check}"

case "$cmd" in
  init)
    init_immutable
    ;;
  check)
    check_immutable
    ;;
  *)
    echo "Usage: $0 {init|check}"
    exit 1
    ;;
esac
