#!/usr/bin/env bash
# CONSTELLATION 25 - MASTER CONSOLIDATOR
set -eo pipefail

WORKSPACE="$HOME/constellation25_workspace"
REPOS_DIR="$WORKSPACE/repositories"
LOG="$WORKSPACE/.constellation25/swarm.log"
mkdir -p "$REPOS_DIR" "$(dirname "$LOG")"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

clear
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  CONSTELLATION 25 - MASTER CONSOLIDATOR                  ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Fetch repos
log "Fetching repositories..."
repos_file="$WORKSPACE/repos_list.txt"
> "$repos_file"

for target in "Faceprintpay" "FacePrintPay"; do
  page=1
  while [ $page -le 5 ]; do
    response=$(curl -s "https://api.github.com/users/$target/repos?per_page=100&page=$page" 2>/dev/null || echo "[]")
    [ "$response" = "[]" ] && break
    echo "$response" | jq -r '.[] | select(.private == false) | "\(.name) \(.html_url)"' >> "$repos_file" 2>/dev/null || true
    ((page++))
    sleep 1
  done
done

sort -u "$repos_file" -o "$repos_file"
total=$(wc -l < "$repos_file")
log "Found $total repositories"

# Clone
success=0; count=0
while read -r name url; do
  [ -z "$name" ] && continue
  ((count++))
  echo -ne "[$count/$total] $name... "
  if [ -d "$REPOS_DIR/$name/.git" ]; then
    echo "✓ (exists)"
    ((success++))
    continue
  fi
  if timeout 30 git clone --depth 1 "$url" "$REPOS_DIR/$name" &>/dev/null; then
    echo "✓"
    ((success++))
  else
    echo "✗"
    mkdir -p "$REPOS_DIR/$name"
  fi
  sleep 1
done < "$repos_file"

echo "✅ Cloned $success/$total repositories"
log "Clone complete: $success/$total"
