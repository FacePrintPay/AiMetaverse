#!/data/data/com.termux/files/usr/bin/bash
# Ultimate Artifact Recovery Script
# Captures EVERYTHING from Downloads, GCP, and all Gmail accounts

set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
ROOT="$HOME/ULTIMATE_RECOVERY_$TS"
mkdir -p "$ROOT"/{downloads,gcp,gmail_drives,manifests}

log() { echo "[$(date +%H:%M:%S)] $*"; }

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     ULTIMATE ARTIFACT RECOVERY - FULL SWEEP              ║"
echo "║  Downloads + GCP Buckets + All Gmail Drives              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════
# 1. ANDROID DOWNLOADS - DEEP RECURSIVE SCAN
# ═══════════════════════════════════════════════════════════
log "📱 PHASE 1: Android Downloads Deep Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for DL_PATH in /storage/emulated/0/Download /sdcard/Download /storage/emulated/0/Documents /sdcard/Documents; do
  [ ! -d "$DL_PATH" ] && continue
  
  log "Scanning: $DL_PATH"
  
  # Copy ALL files matching our patterns (very aggressive)
  find "$DL_PATH" -type f \( \
    -iname "*.html" -o -iname "*.htm" -o \
    -iname "*.sh" -o -iname "*.bash" -o \
    -iname "*.py" -o -iname "*.js" -o -iname "*.ts" -o \
    -iname "*.json" -o -iname "*.yaml" -o -iname "*.yml" -o \
    -iname "*.csv" -o -iname "*.txt" -o -iname "*.md" -o \
    -iname "*.zip" -o -iname "*.tar*" -o -iname "*.gz" -o \
    -iname "*.pdf" -o -iname "*.docx" -o -iname "*.doc" -o \
    -iname "*sovereign*" -o -iname "*cygnus*" -o -iname "*aimetaverse*" -o \
    -iname "*vercel*" -o -iname "*thread_log*" -o -iname "*index*" -o \
    -iname "*swarm*" -o -iname "*planetary*" -o -iname "*chronos*" -o \
    -iname "*basher*" -o -iname "*push2git*" -o -iname "*intel*" -o \
    -iname "*investor*" -o -iname "*cygel*" -o -iname "*faceprintpay*" -o \
    -iname "*openai*" -o -iname "*complaint*" -o -iname "*legal*" \
  \) 2>/dev/null | while read -r file; do
    # Preserve directory structure
    rel_path="${file#$DL_PATH/}"
    dest="$ROOT/downloads/$(basename "$DL_PATH")/$rel_path"
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest" 2>/dev/null || true
  done
done

DL_COUNT=$(find "$ROOT/downloads" -type f 2>/dev/null | wc -l)
log "✅ Downloaded: $DL_COUNT files from Android storage"

# ═══════════════════════════════════════════════════════════
# 2. GCP BUCKETS - ALL ACCESSIBLE BUCKETS
# ═══════════════════════════════════════════════════════════
log ""
log "☁️  PHASE 2: GCP Bucket Recovery"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

GCP_REMOTES=(
  "aimetaverse-gcs"
  "aimetaverse-d40f4-gcs"
  "sovereigngtp-gcs"
  "faceprintpay-gcs"
)

for remote in "${GCP_REMOTES[@]}"; do
  log "Testing GCP remote: $remote"
  
  if rclone lsd "${remote}:" --max-depth 1 &>/dev/null; then
    log "✅ Accessible: $remote"
    
    # Pull EVERYTHING (no filters - grab it all)
    rclone copy "${remote}:" "$ROOT/gcp/$remote" \
      --transfers 100 \
      --checkers 100 \
      --stats 10s \
      --ignore-errors \
      --drive-export-formats pdf \
      -P
    
    count=$(find "$ROOT/gcp/$remote" -type f 2>/dev/null | wc -l)
    log "📦 Pulled $count files from $remote"
  else
    log "⚠️  Not configured: $remote"
  fi
done

# ═══════════════════════════════════════════════════════════
# 3. GMAIL DRIVES - COMPREHENSIVE PULL
# ═══════════════════════════════════════════════════════════
log ""
log "📧 PHASE 3: Gmail Drive Recovery (All Accounts)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

GMAIL_REMOTES=(
  "CyGeL.co@gmail.com"
  "hempchoices@gmail.com"
  "iconosys4@gmail.com"
  "CyGeL_white_gmail_com"
  "faceprintpay_gmail_com"
  "hempchoices_gmail_com"
  "kre8tivekonceptz_gmail_com"
  "cbdh2o_gmail_com"
)

for remote in "${GMAIL_REMOTES[@]}"; do
  safe_name=$(echo "$remote" | tr '@:.' '_' | sed 's/_$//')
  
  log "Checking Gmail: $remote"
  
  if ! rclone lsd "${remote}:" --max-depth 1 &>/dev/null; then
    log "⚠️  Not authenticated: $remote"
    continue
  fi
  
  log "✅ Pulling from: $remote"
  
  # Create aggressive filter - capture EVERYTHING relevant
  FILTER=$(mktemp)
  cat > "$FILTER" <<'FILT'
# Sovereign/Project names
+ **/*sovereign*/**
+ **/*Sovereign*/**
+ **/*aimetaverse*/**
+ **/*AiMetaverse*/**
+ **/*faceprintpay*/**
+ **/*FacePrintPay*/**
+ **/*cygnus*/**
+ **/*CygNus*/**
+ **/*yesquid*/**
+ **/*YesQuid*/**
+ **/*chronos*/**
+ **/*pathos*/**
+ **/*helio*/**
+ **/*jupiter*/**

# All code
+ *.py
+ *.pyw
+ *.js
+ *.jsx
+ *.ts
+ *.tsx
+ *.html
+ *.htm
+ *.css
+ *.scss
+ *.sh
+ *.bash

# All configs
+ *.json
+ *.yaml
+ *.yml
+ *.toml
+ *.ini
+ *.env
+ *Dockerfile*
+ *docker-compose*

# All docs
+ *.md
+ *.txt
+ *.pdf
+ *.doc
+ *.docx
+ *.csv

# Archives
+ *.zip
+ *.tar*
+ *.gz

# Screenshots & logs
+ *screenshot*
+ *Screenshot*
+ *thread_log*
+ *swarm*
+ *index*

# Reject rest
- *
FILT
  
  # Normal files
  rclone copy "${remote}:" "$ROOT/gmail_drives/$safe_name/normal" \
    --filter-from "$FILTER" \
    --ignore-case \
    --drive-shared-with-me \
    --transfers 50 \
    --checkers 80 \
    --drive-chunk-size 256M \
    --stats 15s \
    --drive-export-formats pdf \
    --skip-links \
    --ignore-errors \
    -P
  
  # Trashed files
  rclone copy "${remote}:" "$ROOT/gmail_drives/$safe_name/trashed" \
    --drive-trashed-only \
    --filter-from "$FILTER" \
    --ignore-case \
    --drive-shared-with-me \
    --transfers 30 \
    --stats 15s \
    --drive-export-formats pdf \
    --skip-links \
    --ignore-errors \
    -P || true
  
  rm -f "$FILTER"
  
  normal=$(find "$ROOT/gmail_drives/$safe_name/normal" -type f 2>/dev/null | wc -l)
  trash=$(find "$ROOT/gmail_drives/$safe_name/trashed" -type f 2>/dev/null | wc -l)
  log "📦 $safe_name: normal=$normal, trashed=$trash"
done

# ═══════════════════════════════════════════════════════════
# 4. GENERATE MANIFESTS
# ═══════════════════════════════════════════════════════════
log ""
log "📝 PHASE 4: Generating Manifests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# File inventory
find "$ROOT" -type f > "$ROOT/manifests/complete_file_list.txt"

# SHA256 hashes
find "$ROOT" -type f -exec sha256sum {} \; > "$ROOT/manifests/sha256_manifest.txt" 2>/dev/null

# Stats by type
{
  echo "RECOVERY STATISTICS - $TS"
  echo "════════════════════════════════════════"
  echo ""
  echo "DOWNLOADS:"
  echo "  Total files: $DL_COUNT"
  echo ""
  echo "GCP BUCKETS:"
  for remote in "${GCP_REMOTES[@]}"; do
    count=$(find "$ROOT/gcp/$remote" -type f 2>/dev/null | wc -l || echo 0)
    echo "  $remote: $count files"
  done
  echo ""
  echo "GMAIL DRIVES:"
  for remote in "${GMAIL_REMOTES[@]}"; do
    safe=$(echo "$remote" | tr '@:.' '_' | sed 's/_$//')
    n=$(find "$ROOT/gmail_drives/$safe/normal" -type f 2>/dev/null | wc -l || echo 0)
    t=$(find "$ROOT/gmail_drives/$safe/trashed" -type f 2>/dev/null | wc -l || echo 0)
    total=$((n + t))
    echo "  $remote: $total files (normal=$n, trashed=$t)"
  done
  echo ""
  echo "TOTAL FILES RECOVERED:"
  total=$(find "$ROOT" -type f | wc -l)
  echo "  $total files"
  echo ""
  echo "STORAGE USED:"
  du -sh "$ROOT" | cut -f1
} > "$ROOT/manifests/RECOVERY_SUMMARY.txt"

cat "$ROOT/manifests/RECOVERY_SUMMARY.txt"

# ═══════════════════════════════════════════════════════════
# 5. COMPRESS FINAL ARCHIVE
# ═══════════════════════════════════════════════════════════
log ""
log "🗜️  PHASE 5: Creating Final Archive"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$(dirname "$ROOT")"
tar czf "ULTIMATE_RECOVERY_${TS}.tar.gz" "$(basename "$ROOT")"

SIZE=$(du -h "ULTIMATE_RECOVERY_${TS}.tar.gz" | cut -f1)
FILES=$(tar tzf "ULTIMATE_RECOVERY_${TS}.tar.gz" | wc -l)

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           🎉 RECOVERY COMPLETE 🎉                        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Archive: ULTIMATE_RECOVERY_${TS}.tar.gz"
echo "Size   : $SIZE"
echo "Files  : $FILES"
echo "Path   : $(pwd)/ULTIMATE_RECOVERY_${TS}.tar.gz"
echo ""
echo "Extracted data available at:"
echo "  $ROOT"
echo ""
echo "✅ Downloads captured"
echo "✅ GCP buckets recovered"
echo "✅ Gmail drives archived"
echo "✅ Manifests generated"
echo "✅ SHA256 hashes recorded"
echo ""
echo "You now own EVERYTHING. 🔥"
echo ""
