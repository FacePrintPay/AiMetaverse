#!/bin/bash
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Obsidian Vault Merger - Constellation25         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

SOURCE_VAULTS=()
DEST_VAULT=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source) SOURCE_VAULTS+=("$2"); shift 2 ;;
        -d|--dest) DEST_VAULT="$2"; shift 2 ;;
        -f|--force) FORCE=true; shift ;;
        *) shift ;;
    esac
done

if [[ ${#SOURCE_VAULTS[@]} -lt 2 ]]; then
    echo -e "${RED}Error: At least 2 source vaults required${NC}"
    echo "Usage: $0 -s /vault1 -s /vault2 -d /destination"
    exit 1
fi

if [[ -z "$DEST_VAULT" ]]; then
    echo -e "${RED}Error: Destination vault required${NC}"
    exit 1
fi

echo -e "${GREEN}Source vaults: ${#SOURCE_VAULTS[@]}${NC}"
echo -e "${GREEN}Destination: ${DEST_VAULT}${NC}"
echo ""

mkdir -p "$DEST_VAULT"

for vault in "${SOURCE_VAULTS[@]}"; do
    vault_name=$(basename "$vault")
    echo -e "${BLUE}Merging: ${vault_name}${NC}"
    
    if [[ ! -d "$vault" ]]; then
        echo -e "${RED}  Warning: ${vault} does not exist${NC}"
        continue
    fi
    
    find "$vault" -type f -not -path "*/.git/*" | while read file; do
        rel_path="${file#$vault/}"
        dest_file="${DEST_VAULT}/${rel_path}"
        dest_dir=$(dirname "$dest_file")
        
        mkdir -p "$dest_dir"
        
        if [[ -f "$dest_file" ]]; then
            base="${rel_path%.*}"
            ext="${rel_path##*.}"
            if [[ "$base" == "$ext" ]]; then
                new_name="${base}_${vault_name}"
            else
                new_name="${base}_${vault_name}.${ext}"
            fi
            dest_file="${dest_dir}/${new_name}"
            echo -e "${YELLOW}  Conflict: ${rel_path} -> ${new_name}${NC}"
        fi
        
        cp "$file" "$dest_file" 2>/dev/null && echo -e "${GREEN}  ✓ ${rel_path}${NC}" || true
    done
done

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}Merge Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo "Destination: ${DEST_VAULT}"
echo "Files merged: $(find "$DEST_VAULT" -type f 2>/dev/null | wc -l)"
