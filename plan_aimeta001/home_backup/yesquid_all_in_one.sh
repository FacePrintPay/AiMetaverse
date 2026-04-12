#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# YESQUID / PaTHos - ALL-IN-ONE SYSTEM
# - Installs deps
# - Authenticates 6 Google Drives (rclone)
# - Syncs all Drives into vault
# - Carves ALL code-ish files per drive
# - Builds per-drive inventory (hempchoices-style)
# - Compiles global master_source snapshot
# Omnibus mode: log + continue where possible
# ============================================================

set +e  # don't hard-exit on every error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

TS="$(date +%Y%m%d_%H%M%S)"

# Core paths
BASE="$HOME/YesQuidSystem"
EXTRACT_ROOT="$HOME/YesQuidExtracts"
LOG_ROOT="$HOME/YesQuidLogs"
VAULT_ROOT="$BASE/vault"              # where all Drives are synced
MS_ROOT="$BASE/master_source"         # compiled text snapshot

mkdir -p "$BASE" "$EXTRACT_ROOT" "$LOG_ROOT" "$MS_ROOT"

GLOBAL_LOG="$LOG_ROOT/yesquid_all_in_one_$TS.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$GLOBAL_LOG"
}

show_banner() {
  echo -e "${CYAN}"
  cat << 'BANNER'
╔═══════════════════════════════════════════════════════╗
║  YESQUID / PaTHos - ALL-IN-ONE GRAB-IT-ALL SYSTEM    ║
║  Multi-Drive Sync + Code Carve + Inventory + Master  ║
╚═══════════════════════════════════════════════════════╝
BANNER
  echo -e "${NC}"
}

# Google accounts (remotes will be derived from these)
ACCOUNTS=(
  "CyGeL.white@gmail.com"
  "CyGeL.co@gmail.com"
  "iconosys4@gmail.com"
  "hempchoices@gmail.com"
  "CBDh2o@gmail.com"
  "Faceprintpay@gmail.com"
)

remote_name_for() {
  # turn email into a safe rclone remote name
  echo "$1" | sed 's/@/_/g' | sed 's/\./_/g'
}

# ============================================================
# STEP 1: Install System Dependencies
# ============================================================
install_deps() {
  log "[STEP] Installing Termux + Python + rclone deps"

  echo -e "${YELLOW}Updating package lists...${NC}"
  pkg update -y >>"$GLOBAL_LOG" 2>&1

  echo -e "${YELLOW}Installing packages (python, git, rclone, curl, jq)...${NC}"
  pkg install -y python git rclone curl wget jq findutils coreutils >>"$GLOBAL_LOG" 2>&1

  echo -e "${YELLOW}Upgrading pip + base Python packages...${NC}"
  pip install --upgrade pip >>"$GLOBAL_LOG" 2>&1
  pip install --upgrade requests pyyaml >>"$GLOBAL_LOG" 2>&1

  echo -e "${GREEN}✅ Dependencies installed${NC}"
}

# ============================================================
# STEP 2: Authenticate 6 Google Drives via rclone
# ============================================================
authenticate_drives() {
  log "[STEP] Authenticating Google Drives"

  if ! command -v rclone >/dev/null 2>&1; then
    echo -e "${RED}rclone not found. Run install step first.${NC}"
    return 1
  fi

  echo -e "${CYAN}Authenticating 6 Google Drive accounts via rclone...${NC}"
  echo -e "${YELLOW}You will see browser prompts for OAuth. Close and reopen between accounts as needed.${NC}"
  echo ""

  local success=0
  local failed=0

  for i in "${!ACCOUNTS[@]}"; do
    local email="${ACCOUNTS[$i]}"
    local remote
    remote="$(remote_name_for "$email")"
    local idx=$((i+1))

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} [$idx/6] Account: ${BLUE}$email${NC}"
    echo -e "${CYAN} Remote name: ${BLUE}$remote${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Already configured?
    if rclone lsd "${remote}:" >/dev/null 2>&1; then
      echo -e "${GREEN}  ✓ Already authenticated${NC}"
      log "[AUTH] $email already authenticated as $remote"
      success=$((success+1))
      continue
    fi

    echo -e "${YELLOW}Starting rclone config for ${email}...${NC}"
    echo -e "${YELLOW}Follow prompts in browser to approve access.${NC}"
    echo -e "${YELLOW}Close any previous rclone tabs FIRST.${NC}"
    echo ""

    # Kill stray rclone auth servers
    pkill -f "rclone.*http" 2>/dev/null || true
    sleep 1

    # Delete any old config with same remote name
    rclone config delete "$remote" >/dev/null 2>&1 || true

    # Run guided config (interactive). User picks "drive" etc.
    # Using "rclone config create" programmatically is possible but brittle;
    # guided mode is more reliable for multiple accounts.
    rclone config create "$remote" drive \
      --config="$HOME/.config/rclone/rclone.conf" \
      --drive-scope="drive" 2>&1 | tee -a "$GLOBAL_LOG"

    sleep 2

    if rclone lsd "${remote}:" >/dev/null 2>&1; then
      echo -e "${GREEN}  ✓ $email authenticated as $remote${NC}"
      log "[AUTH] $email OK"
      success=$((success+1))
    else
      echo -e "${RED}  ✗ Authentication failed for $email${NC}"
      log "[AUTH] $email FAILED"
      failed=$((failed+1))
    fi
  done

  echo ""
  echo -e "${CYAN}Auth summary:${NC}"
  echo -e "${GREEN}  ✓ Success: $success${NC}"
  echo -e "${RED}  ✗ Failed:  $failed${NC}"
}

# ============================================================
# STEP 3: Sync all Drives into vault
# ============================================================
sync_all_drives() {
  log "[STEP] Syncing all Drives → vault"

  mkdir -p "$VAULT_ROOT"

  local synced=0
  local failed=0
  local start
  start=$(date +%s)

  for i in "${!ACCOUNTS[@]}"; do
    local email="${ACCOUNTS[$i]}"
    local remote
    remote="$(remote_name_for "$email")"
    local local_dir="$VAULT_ROOT/${remote}"
    local idx=$((i+1))

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} [$idx/6] Syncing ${BLUE}$email${NC}"
    echo -e "${CYAN} Remote: ${BLUE}$remote:${NC}"
    echo -e "${CYAN} Local : ${BLUE}$local_dir${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if ! rclone lsd "${remote}:" >/dev/null 2>&1; then
      echo -e "${YELLOW}  ⚠ Not authenticated / unreachable, skipping${NC}"
      log "[SYNC] $email skipped (no remote)"
      continue
    fi

    mkdir -p "$local_dir"

    local sync_log="$LOG_ROOT/${remote}_sync_$TS.log"

    echo -e "${YELLOW}  → Sync in progress...${NC}"
    rclone sync "${remote}:" "$local_dir" \
      --progress \
      --stats 20s \
      --transfers 4 \
      --checkers 8 \
      --drive-chunk-size 64M \
      --log-file "$sync_log" \
      --log-level INFO

    if [ $? -eq 0 ]; then
      synced=$((synced+1))
      log "[SYNC] $email → $local_dir OK"
      local files
      local size
      files=$(find "$local_dir" -type f 2>/dev/null | wc -l || echo 0)
      size=$(du -sh "$local_dir" 2>/dev/null | cut -f1)
      echo -e "${GREEN}  ✓ Synced successfully${NC}"
      echo -e "${CYAN}    Files: $files | Size: $size${NC}"
    else
      failed=$((failed+1))
      log "[SYNC] $email FAILED"
      echo -e "${RED}  ✗ Sync failed for $email${NC}"
    fi
  done

  local end
  end=$(date +%s)
  local dur=$((end - start))

  echo ""
  echo -e "${CYAN}Sync summary:${NC}"
  echo -e "${GREEN}  ✓ Synced: $synced${NC}"
  echo -e "${RED}  ✗ Failed: $failed${NC}"
  echo -e "${CYAN}  ⏱ Duration: ${dur}s${NC}"
}

# ============================================================
# STEP 4: Per-drive CODE CARVE + INVENTORY
# ============================================================

# Build inventory for a carved drive
build_inventory() {
  local CODE_DIR="$1"
  local INV_DIR="$2"

  mkdir -p "$INV_DIR"
  log "[INV] Building inventory for $CODE_DIR"

  # Top dirs
  find "$CODE_DIR" -maxdepth 3 -type d 2>/dev/null | sort > "$INV_DIR/dirs_top_3.txt"

  # Node / TS
  {
    find "$CODE_DIR" -name "package.json" -o -name "pnpm-lock.yaml" -o -name "yarn.lock" 2>/dev/null
  } | sort > "$INV_DIR/node_projects.txt"

  # Python
  {
    find "$CODE_DIR" -name "requirements.txt" -o -name "pyproject.toml" -o -name "Pipfile" 2>/dev/null
  } | sort > "$INV_DIR/python_projects.txt"

  # Gradle / Java / Android
  {
    find "$CODE_DIR" \
      -name "build.gradle" -o -name "build.gradle.kts" \
      -o -name "settings.gradle" -o -name "settings.gradle.kts" \
      -o -name "AndroidManifest.xml" 2>/dev/null
  } | sort > "$INV_DIR/gradle_projects.txt"

  # Go / Rust / misc
  {
    find "$CODE_DIR" -name "go.mod" -o -name "Cargo.toml" -o -name "Makefile" 2>/dev/null
  } | sort > "$INV_DIR/go_rust_misc.txt"

  # Brand hits
  {
    grep -RIn \
      -e "AiMetaVerse" \
      -e "Total Recall" \
      -e "TotalRecall" \
      -e "Planetary Agents" \
      -e "PlanetaryAgents" \
      -e "YesQuid" \
      -e "PaTHos" \
      -e "SovereignGTP" \
      "$CODE_DIR" 2>/dev/null || true
  } > "$INV_DIR/core_brands_hits.txt"

  local count
  count=$(find "$CODE_DIR" -type f 2>/dev/null | wc -l || echo 0)
  echo "$count" > "$INV_DIR/file_count.txt"

  log "[INV] Inventory complete for $CODE_DIR (files=$count)"
}

# Carve a single drive
carve_drive() {
  local drive_dir="$1"   # root of that drive in vault
  local slug="$2"        # folder base name
  local STAGE="$EXTRACT_ROOT/${slug}_stage"
  local CODE_DIR="$STAGE/code_recovery"
  local INV_DIR="$STAGE/inventory"
  local LOG_FILE="$LOG_ROOT/${slug}_code_carve_$TS.log"

  mkdir -p "$STAGE" "$CODE_DIR" "$INV_DIR"

  echo -e "${CYAN}================================================${NC}" | tee -a "$LOG_FILE"
  echo -e "${CYAN} YESQUID ALL-DRIVES CODE CARVE                  ${NC}" | tee -a "$LOG_FILE"
  echo -e "${CYAN} DRIVE ROOT: ${BLUE}$drive_dir${NC}"             | tee -a "$LOG_FILE"
  echo -e "${CYAN} STAGE     : ${BLUE}$STAGE${NC}"                 | tee -a "$LOG_FILE"
  echo -e "${CYAN} LOG       : ${BLUE}$LOG_FILE${NC}"              | tee -a "$LOG_FILE"
  echo -e "${CYAN}================================================${NC}" | tee -a "$LOG_FILE"

  log "[CARVE] Scanning $drive_dir for code-ish files"

  # Find all code-ish files directly with find expression
  local LIST_FILE="$STAGE/matched_files_$TS.list"

  find "$drive_dir" -type f \
    \( \
      -name '*.sh' -o -name '*.bash' -o -name '*.zsh' \
      -o -name '*.py' -o -name '*.ipynb' \
      -o -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' \
      -o -name '*.json' \
      -o -name '*.yaml' -o -name '*.yml' \
      -o -name '*.toml' -o -name '*.ini' -o -name '*.cfg' -o -name '*.env' \
      -o -name '*.php' -o -name '*.rb' \
      -o -name '*.go' -o -name '*.rs' \
      -o -name '*.java' -o -name '*.kt' -o -name '*.swift' \
      -o -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \
      -o -name '*.sql' \
      -o -name '*.html' -o -name '*.htm' \
      -o -name '*.css' -o -name '*.scss' -o -name '*.sass' -o -name '*.less' \
      -o -name '*.md' \
      -o -name 'Dockerfile' -o -name '*.dockerfile' \
    \) 2>/dev/null | sort > "$LIST_FILE"

  local matched
  matched=$(wc -l < "$LIST_FILE" 2>/dev/null || echo 0)
  echo "[+] Files matched: $matched" | tee -a "$LOG_FILE"

  if [ "$matched" -eq 0 ]; then
    echo "[!] WARNING: No files matched for $slug" | tee -a "$LOG_FILE"
    log "[CARVE] $slug matched 0 files"
    return 0
  fi

  echo "[*] Copying files with parents preserved..." | tee -a "$LOG_FILE"

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    local rel="${f#$drive_dir/}"
    local dest="$CODE_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest" 2>>"$LOG_FILE" || echo "[WARN] Failed to copy $f" >>"$LOG_FILE"
  done < "$LIST_FILE"

  local final_count
  final_count=$(find "$CODE_DIR" -type f 2>/dev/null | wc -l || echo 0)
  echo "[✓] Code carve complete for $slug" | tee -a "$LOG_FILE"
  echo "[✓] Files in code_recovery: $final_count" | tee -a "$LOG_FILE"
  log "[CARVE] $slug code_recovery count=$final_count"

  # Build inventory like hempchoices pass 2
  build_inventory "$CODE_DIR" "$INV_DIR"

  echo "[DONE] Stage dir: $STAGE" | tee -a "$LOG_FILE"
}

carve_all_drives() {
  log "[STEP] Carving ALL drives from vault into per-drive stages"

  if [ ! -d "$VAULT_ROOT" ]; then
    echo -e "${RED}Vault root not found: $VAULT_ROOT${NC}"
    echo -e "${YELLOW}Run sync step first.${NC}"
    return 1
  fi

  mapfile -t DRIVES < <(find "$VAULT_ROOT" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)

  if [ "${#DRIVES[@]}" -eq 0 ]; then
    echo -e "${RED}No drive directories found under vault: $VAULT_ROOT${NC}"
    return 1
  fi

  echo -e "${CYAN}Discovered vault drive roots:${NC}"
  for d in "${DRIVES[@]}"; do
    echo "  - $d"
  done
  echo ""

  local total=0
  local processed=0

  for d in "${DRIVES[@]}"; do
    total=$((total+1))
    local slug
    slug="$(basename "$d")"

    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA} Processing vault drive: ${slug}${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    carve_drive "$d" "$slug"
    processed=$((processed+1))
  done

  echo ""
  echo -e "${CYAN}Carve summary:${NC}"
  echo -e "${GREEN}  Drives processed: $processed / $total${NC}"
}

# ============================================================
# STEP 5: Master Source Compilation
# ============================================================
compile_master_source() {
  log "[STEP] Compiling global master source snapshot"

  mkdir -p "$MS_ROOT"
  local out_file="$MS_ROOT/master_source_$TS.txt"
  local file_list="$MS_ROOT/source_files_$TS.list"

  # Roots to scan (you can add more)
  local roots=(
    "$BASE"
    "$EXTRACT_ROOT"
    "$VAULT_ROOT"
    "$HOME/projects"
    "$HOME/SovereignGTP"
    "$HOME/TotalRecall"
  )

  echo -e "${YELLOW}Scanning roots for code-ish sources...${NC}"

  local find_cmd="find"
  for root in "${roots[@]}"; do
    [ -d "$root" ] && find_cmd="$find_cmd \"$root\""
  done
  find_cmd="$find_cmd -xdev -type f \( -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.toml' -o -name '*.md' -o -name 'Dockerfile' \) 2>/dev/null"

  # shellcheck disable=SC2086
  eval "$find_cmd" | sort > "$file_list"

  local total
  total=$(wc -l < "$file_list" 2>/dev/null || echo 0)
  echo -e "${GREEN}  ✓ Found $total files for master_source${NC}"

  {
    echo "# =========================================="
    echo "# YESQUID / PaTHos - MASTER SOURCE SNAPSHOT"
    echo "# Timestamp: $(date)"
    echo "# Total files: $total"
    echo "# =========================================="
    echo ""

    while IFS= read -r src; do
      [ -z "$src" ] && continue
      echo ""
      echo "# =========================================="
      echo "# FILE: $src"
      echo "# =========================================="
      echo ""
      sed -e 's/\r$//' "$src" 2>>"$GLOBAL_LOG" || echo "# [WARN] Could not read $src"
      echo ""
    done < "$file_list"
  } > "$out_file"

  local size
  size=$(du -sh "$out_file" 2>/dev/null | cut -f1)
  echo -e "${GREEN}  ✓ master_source built${NC}"
  echo -e "${CYAN}  File: $out_file${NC}"
  echo -e "${CYAN}  Size: $size${NC}"
  log "[MASTER] master_source -> $out_file ($size)"
}

# ============================================================
# Vault Status
# ============================================================
show_vault_status() {
  log "[STEP] Vault status"

  echo -e "${CYAN}Vault status for: ${BLUE}$VAULT_ROOT${NC}"
  if [ ! -d "$VAULT_ROOT" ]; then
    echo -e "${YELLOW}Vault not created yet.${NC}"
    return
  fi

  local total_files=0

  for dir in "$VAULT_ROOT"/*; do
    [ -d "$dir" ] || continue
    local slug
    slug="$(basename "$dir")"
    local files
    local size
    files=$(find "$dir" -type f 2>/dev/null | wc -l || echo 0)
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo -e "${GREEN}$slug${NC}"
    echo "  Files: $files"
    echo "  Size : $size"
    echo ""
    total_files=$((total_files + files))
  done

  echo -e "${CYAN}Total files in vault: $total_files${NC}"
}

# ============================================================
# COMPLETE WORKFLOW
# ============================================================
run_complete_workflow() {
  local start
  start=$(date +%s)

  show_banner
  log "[WORKFLOW] Starting complete run: deps → auth → sync → carve → master"

  install_deps
  authenticate_drives
  sync_all_drives
  carve_all_drives
  compile_master_source

  local end
  end=$(date +%s)
  local dur=$((end - start))
  local min=$((dur / 60))
  local sec=$((dur % 60))

  echo ""
  echo -e "${GREEN}✅ Complete workflow finished in ${min}m ${sec}s${NC}"
  echo -e "${CYAN}Global log: $GLOBAL_LOG${NC}"
}

# ============================================================
# INTERACTIVE MENU
# ============================================================
show_menu() {
  show_banner
  echo -e "${CYAN}Main Menu${NC}"
  echo ""
  echo "  1) Install dependencies"
  echo "  2) Authenticate all 6 Google Drives"
  echo "  3) Sync all Drives into vault"
  echo "  4) Carve ALL drives (code + inventory)"
  echo "  5) Compile global master_source snapshot"
  echo "  6) Show vault status"
  echo "  7) Run COMPLETE workflow (1→5)"
  echo "  0) Exit"
  echo ""
  read -rp "Choose option: " choice

  case "$choice" in
    1) install_deps ;;
    2) install_deps; authenticate_drives ;;
    3) install_deps; sync_all_drives ;;
    4) install_deps; carve_all_drives ;;
    5) install_deps; compile_master_source ;;
    6) show_vault_status ;;
    7) run_complete_workflow ;;
    0) echo -e "${GREEN}Bye.${NC}"; exit 0 ;;
    *) echo -e "${RED}Invalid choice${NC}" ;;
  esac

  echo ""
  read -rp "Press Enter to return to menu..." _
  show_menu
}

# ============================================================
# CLI ENTRYPOINT
# ============================================================
case "${1:-}" in
  --deps)
    install_deps
    ;;
  --auth)
    install_deps
    authenticate_drives
    ;;
  --sync)
    install_deps
    sync_all_drives
    ;;
  --carve)
    install_deps
    carve_all_drives
    ;;
  --master)
    install_deps
    compile_master_source
    ;;
  --vault)
    show_vault_status
    ;;
  --all|--complete)
    run_complete_workflow
    ;;
  --help|-h)
    show_banner
    echo "Usage: $0 [option]"
    echo ""
    echo "  --deps       Install/upgrade dependencies"
    echo "  --auth       Authenticate 6 Google Drives via rclone"
    echo "  --sync       Sync all Drives into vault"
    echo "  --carve      Carve ALL drives (code + inventory per drive)"
    echo "  --master     Compile global master_source snapshot"
    echo "  --vault      Show vault status"
    echo "  --all        Run full pipeline: deps→auth→sync→carve→master"
    echo "  (no args)    Show interactive menu"
    ;;
  *)
    show_menu
    ;;
esac
