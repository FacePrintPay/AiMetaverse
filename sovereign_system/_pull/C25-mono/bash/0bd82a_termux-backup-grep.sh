#!/usr/bin/env bash
# ========================================================
# CONSTELLATION 25 - TERMUX BACKUP & GREP SYSTEM
# Full HOME directory backup, search, and recovery
# ========================================================
set -euo pipefail

HOME_DIR="$HOME"
BACKUP_DIR="$HOME/constellation25-backups"
CURRENT_BACKUP="$BACKUP_DIR/current"
ARCHIVE_DIR="$BACKUP_DIR/archives"
GREP_CACHE="$BACKUP_DIR/grep-cache"
LOG="$BACKUP_DIR/backup.log"

mkdir -p "$BACKUP_DIR" "$ARCHIVE_DIR" "$GREP_CACHE" "$CURRENT_BACKUP"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

log() { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }
success() { log "${GREEN}✅ $1${NC}"; }
warning() { log "${YELLOW}⚠️  $1${NC}"; }
error() { log "${RED}❌ $1${NC}"; }
info() { log "${CYAN}ℹ️  $1${NC}"; }

banner() {
  clear
  cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║   CONSTELLATION 25 - TERMUX BACKUP & GREP SYSTEM          ║
║        Full HOME Directory Management & Search            ║
╚════════════════════════════════════════════════════════════╝
EOF
}

get_size() { du -sh "$1" 2>/dev/null | cut -f1 || echo "N/A"; }
count_files() { find "$1" -type f 2>/dev/null | wc -l || echo "0"; }

backup_home_full() {
  info "Starting FULL HOME directory backup..."
  local timestamp=$(date '+%Y%m%d_%H%M%S')
  local backup_name="termux-home-full_${timestamp}"
  local backup_path="$ARCHIVE_DIR/${backup_name}.tar.gz"
  
  echo ""
  info "Analyzing HOME directory..."
  local home_size=$(get_size "$HOME_DIR")
  local file_count=$(count_files "$HOME_DIR")
  
  echo ""
  echo -e "${CYAN}┌─────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}│ HOME Directory Analysis                 │${NC}"
  echo -e "${CYAN}├─────────────────────────────────────────┤${NC}"
  echo -e "${CYAN}│${NC} Location:    $HOME_DIR"
  echo -e "${CYAN}│${NC} Size:        $home_size"
  echo -e "${CYAN}│${NC} Files:       $file_count"
  echo -e "${CYAN}│${NC} Backup to:   $backup_path"
  echo -e "${CYAN}└─────────────────────────────────────────┘${NC}"
  echo ""
  
  read -p "Proceed with full backup? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    warning "Backup cancelled"
    return 1
  fi
  
  info "Creating compressed backup..."
  tar -czf "$backup_path" \
    --exclude="$HOME_DIR/.cache" \
    --exclude="$HOME_DIR/constellation25-backups" \
    --exclude="$HOME_DIR/.npm" \
    -C "$(dirname "$HOME_DIR")" \
    "$(basename "$HOME_DIR")" 2>&1 | tee -a "$LOG"
  
  if [ $? -eq 0 ]; then
    local backup_size=$(get_size "$backup_path")
    success "Backup created: $backup_size"
    cat > "$ARCHIVE_DIR/${backup_name}.info" << EOF
Backup Created: $(date '+%Y-%m-%d %H:%M:%S')
Source: $HOME_DIR
Original Size: $home_size
Compressed Size: $backup_size
File Count: $file_count
EOF
    return 0
  else
    error "Backup failed!"
    return 1
  fi
}

grep_home_directory() {
  local search_term="$1"
  local output_file="$GREP_CACHE/grep_results_$(date '+%Y%m%d_%H%M%S').txt"
  
  info "Searching for: '$search_term'"
  
  echo "CONSTELLATION 25 - GREP RESULTS" > "$output_file"
  echo "Search Term: $search_term" >> "$output_file"
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
  echo "═══════════════════════════════════════════" >> "$output_file"
  echo "" >> "$output_file"
  
  grep -r -i -n --color=never \
    --exclude-dir=".cache" \
    --exclude-dir="node_modules" \
    --exclude-dir="constellation25-backups" \
    "$search_term" "$HOME_DIR" 2>/dev/null | tee -a "$output_file"
  
  local match_count=$(grep -c "$search_term" "$output_file" 2>/dev/null || echo "0")
  
  echo ""
  success "Found $match_count matches"
  success "Results: $output_file"
}

list_backups() {
  info "Available backups:"
  echo ""
  
  if [ ! "$(ls -A $ARCHIVE_DIR 2>/dev/null)" ]; then
    warning "No backups found"
    return 0
  fi
  
  local count=0
  for backup in "$ARCHIVE_DIR"/*.tar.gz; do
    if [ -f "$backup" ]; then
      count=$((count + 1))
      local name=$(basename "$backup")
      local size=$(get_size "$backup")
      echo -e "${CYAN}[$count]${NC} $name ($size)"
    fi
  done
  
  success "Total: $count backups"
}

main_menu() {
  while true; do
    banner
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      MAIN MENU                            ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  [1] Full HOME backup"
    echo -e "${CYAN}║${NC}  [2] Quick grep search"
    echo -e "${CYAN}║${NC}  [3] List all backups"
    echo -e "${CYAN}║${NC}  [4] Exit"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Choose [1-4]: " choice
    
    case $choice in
      1) backup_home_full ;;
      2) 
        read -p "Search term: " term
        grep_home_directory "$term"
        ;;
      3) list_backups ;;
      4) success "Goodbye!"; exit 0 ;;
      *) error "Invalid option" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
  done
}

main_menu
