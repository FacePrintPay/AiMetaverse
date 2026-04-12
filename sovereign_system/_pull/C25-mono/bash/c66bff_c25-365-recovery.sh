#!/data/data/com.termux/files/usr/bin/bash

# =============================================================================
# CONSTELLATION25 365-DAY RECOVERY DAEMON
# Mission: Parse 365 Days of Logs/History, Identify Failures, Auto-Fix & Clean
# Author: DevOps GuruCTO
# Agents: PA-01 to PA-25 Embedded
# =============================================================================

set -o pipefail

# --- Configuration ---
ROOT="$HOME"
HISTORY_FILE="$HOME/.bash_history"
LOG_DIRS=("$HOME/constellation25/logs" "$HOME/total-recall-recovery*" "$HOME/.npm/_logs")
OUTPUT_DIR="$HOME/constellation25/recovery-output"
TODO_LIST="$OUTPUT_DIR/TODO_DEPLOY_LIST.md"
RECOVERY_LOG="$OUTPUT_DIR/recovery_execution.log"
STORAGE_THRESHOLD_MB=500

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Initialization ---
mkdir -p "$OUTPUT_DIR"
echo "[$(date)] === 365-DAY RECOVERY STARTED ===" > "$RECOVERY_LOG"

# --- Agent Functions ---

log() {
    echo -e "${BLUE}[C25 SYSTEM]${NC} $1"
    echo "[$(date '+%H:%M:%S')] $1" >> "$RECOVERY_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%H:%M:%S')] ERROR: $1" >> "$RECOVERY_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%H:%M:%S')] SUCCESS: $1" >> "$RECOVERY_LOG"
}

# --- PA-25: Storage Guardian (Auto-Clear) ---
auto_clear() {
    log "🛡️ PA-25: Checking Storage..."
    local available=$(df -m $HOME | awk 'NR==2 {print $4}')
    if [ "$available" -lt "$STORAGE_THRESHOLD_MB" ]; then
        log "🛡️ PA-25: Storage Low (${available}MB). Purging..."
        npm cache clean --force 2>/dev/null
        pkg clean -y 2>/dev/null
        find $ROOT -type d -name "node_modules" -mtime +7 -exec rm -rf {} \; 2>/dev/null
        find $ROOT -type f -name "*.log" -mtime +7 -delete 2>/dev/null
        success "🛡️ PA-25: Storage Cleared"
    fi
}

# --- PA-01: Repo Miner (Scan History & Logs) ---
scan_failures() {
    log "🔍 PA-01: Scanning 365 Days of History & Logs..."
    local temp_failures="$OUTPUT_TEMP/failures.txt"
    mkdir -p "$OUTPUT_TEMP"

    # 1. Scan Bash History for repeated commands (indicates failure/retry)
    if [ -f "$HISTORY_FILE" ]; then
        sort "$HISTORY_FILE" | uniq -c | sort -rn | awk '$1 > 3 {print $2}' > "$OUTPUT_TEMP/repeated_cmds.txt"
    fi

    # 2. Scan Log Files for Errors
    for dir in "${LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            grep -r -i "error\|failed\|not found\|no such file" "$dir" 2>/dev/null | \
            grep -v "Binary" >> "$OUTPUT_TEMP/log_errors.txt"
        fi
    done

    # 3. Scan for Missing Directories referenced in logs
    grep -r -oE "/data/data/com.termux/files/home/[a-zA-Z0-9/_-]+" "$OUTPUT_TEMP/log_errors.txt" 2>/dev/null | \
    sort -u > "$OUTPUT_TEMP/missing_paths.txt"

    success "🔍 PA-01: Scan Complete. Generating TODO List..."
}

# --- PA-24: NLP2CODE (Generate TODO List) ---
generate_todo() {
    log "📝 PA-24: Generating TODO_DEPLOY_LIST.md..."
    cat > "$TODO_LIST" << TODOEOF
# Constellation25 Recovery TODO List
Generated: $(date)
Source: 365 Days of Termux History & Logs

## 1. Failed Builds
- [ ] Review repeated commands
- [ ] Re-run interrupted builds

## 2. Missing Directories
- [ ] Create missing paths

## 3. Package Errors
- [ ] Re-install failed packages

## 4. Deployment Targets
- [ ] Vercel
- [ ] GitHub
- [ ] Local Host

TODOEOF

    # Append findings
    if [ -f "$OUTPUT_TEMP/log_errors.txt" ]; then
        echo "## Log Errors Found" >> "$TODO_LIST"
        cat "$OUTPUT_TEMP/log_errors.txt" >> "$TODO_LIST"
    fi
}

# --- PA-03: Termux Wizard (Auto-Fix Logic) ---
auto_fix() {
    log "🔧 PA-03: Attempting Auto-Fixes..."

    # 1. Fix Missing Directories
    if [ -f "$OUTPUT_TEMP/missing_paths.txt" ]; then
        while IFS= read -r path; do
            if [ ! -d "$path" ]; then
                log "🔧 PA-03: Creating missing dir: $path"
                mkdir -p "$path" 2>/dev/null || error "Failed to create $path"
            fi
        done < "$OUTPUT_TEMP/missing_paths.txt"
    fi

    # 2. Fix Failed Installs (Detect 'npm install' failures in logs)
    if grep -q "npm install" "$OUTPUT_TEMP/log_errors.txt" 2>/dev/null; then
        log "🔧 PA-03: Detected npm failures. Cleaning & Retrying..."
        npm cache clean --force
        # Note: We don't blindly re-run all npm installs, just clean cache
        success "🔧 PA-03: NPM Cache Cleaned"
    fi

    # 3. Fix Git Interrupts (Remove lock files)
    find $ROOT -name ".git/index.lock" -delete 2>/dev/null
    log "🔧 PA-03: Git locks cleared"

    auto_clear
}

# --- PA-22: Build Engineer (Re-Run Interrupted Builds) ---
rebuild_interrupted() {
    log "🏗️ PA-22: Identifying Interrupted Builds..."
    
    # Look for package.json without node_modules (indicates interrupted install)
    find $ROOT -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | \
    while read -r pkg; do
        dir=$(dirname "$pkg")
        if [ ! -d "$dir/node_modules" ]; then
            log "🏗️ PA-22: Found incomplete build: $dir"
            echo "- [ ] Rebuild: $dir" >> "$TODO_LIST"
            # Optional: Auto-run npm install here if storage permits
            # cd "$dir" && npm install --legacy-peer-deps && auto_clear
        fi
    done

    auto_clear
}

# --- Main Execution ---
main() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  C25 365-DAY RECOVERY DAEMON               ${NC}"
    echo -e "${BLUE}  Agents: PA-01, PA-03, PA-22, PA-24, PA-25  ${NC}"
    echo -e "${BLUE}============================================${NC}"

    OUTPUT_TEMP="$OUTPUT_DIR/temp_scan"
    mkdir -p "$OUTPUT_TEMP"

    # Phase 1: Scan
    scan_failures
    
    # Phase 2: Plan
    generate_todo
    
    # Phase 3: Fix
    auto_fix
    
    # Phase 4: Build Recovery
    rebuild_interrupted
    
    # Phase 5: Final Cleanup
    auto_clear
    rm -rf "$OUTPUT_TEMP"
    
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  RECOVERY COMPLETE                         ${NC}"
    echo -e "${GREEN}  TODO List: $TODO_LIST                     ${NC}"
    echo -e "${GREEN}============================================${NC}"
}

main "$@"
