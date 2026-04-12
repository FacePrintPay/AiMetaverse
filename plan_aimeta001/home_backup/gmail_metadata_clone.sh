#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
ROOT="$HOME/CyGel_LLM_Archive"
OUT="$ROOT/raw_exports/gmail_METADATA_$TS"
mkdir -p "$OUT"/{gmail_drives,termux,downloads,metadata}

log() { printf '[%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$*"; }

log "GMAIL METADATA CLONE – SOVEREIGN STACK ONLY"
log "Root: $OUT"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REMOTES=(
  "CyGeL.co@gmail.com"
  "hempchoices@gmail.com"
  "iconosys4@gmail.com"
  "CyGeL_white_gmail_com"
  "faceprintpay_gmail_com"
  "hempchoices_gmail_com"
  "kre8tivekonceptz_gmail_com"
  "cbdh2o_gmail_com"
)

for remote in "${REMOTES[@]}"; do
  safe_name=$(echo "$remote" | tr '@:.' '_' | sed 's/_$//')
  log "Pulling $remote → $safe_name"

  rclone lsd "${remote}:" --max-depth 1 &>/dev/null || { log "SKIP (no auth)"; continue; }

  FILTER=$(mktemp)
  cat > "$FILTER" <<'FILT'
+ *sovereign*
+ *Sovereign*
+ *PaTHos*
+ *pathos*
+ *AiMetaverse*
+ *VideoCourts*
+ *FacePrintPay*
+ *YesQuid*
+ *Chronos*
+ *Helio*
+ *screenshot*
+ *Screenshot*
+ *CHATGPT*
+ *ChatGPT*
+ *GROK*
+ *.py
+ *.pyw
+ *.js
+ *.jsx
+ *.ts
+ *.tsx
+ *.mjs
+ *.cjs
+ *.sh
+ *.bash
+ *.zsh
+ *.json
+ *.yaml
+ *.yml
+ *.toml
+ *.ini
+ *.env
+ *.md
+ *.mdx
+ *.pdf
+ *.log
+ *.ipynb
+ *.html
+ *.htm
+ *.css
+ *.scss
+ *.sass
+ *.vue
+ *.svelte
+ *.php
+ *.rb
+ *.go
+ *.rs
+ *.java
+ *.kt
+ *.swift
+ *.c
+ *.cpp
+ *.h
+ *.sql
+ *.xml
+ *.csv
+ *.txt
+ .gitignore
+ .env*
+ .config
+ Dockerfile
+ docker-compose*
+ package.json
+ package-lock.json
+ requirements.txt
+ Cargo.toml
+ go.mod
+ pom.xml
- *
FILT

  # normal files
  rclone copy "${remote}:" "$OUT/gmail_drives/$safe_name/normal" \
    --filter-from "$FILTER" --ignore-case \
    --drive-shared-with-me --transfers 20 --checkers 40 \
    --drive-chunk-size 256M --stats 20s -P \
    --drive-export-formats pdf \
    --skip-links \
    --ignore-errors \
    --no-traverse \
    --include-from "$FILTER" \
    --log-level ERROR 2>&1 | grep -v "cannotDownloadFile" || true

  # trashed files
  rclone copy "${remote}:" "$OUT/gmail_drives/$safe_name/trashed" \
    --drive-trashed-only --filter-from "$FILTER" --ignore-case \
    --drive-shared-with-me --transfers 12 --stats 20s -P \
    --drive-export-formats pdf \
    --skip-links \
    --ignore-errors || true

  rm -f "$FILTER"

  n=$(find "$OUT/gmail_drives/$safe_name/normal" -type f 2>/dev/null | wc -l)
  t=$(find "$OUT/gmail_drives/$safe_name/trashed" -type f 2>/dev/null | wc -l)
  log "DONE $safe_name → normal:$n trashed:$t"
done

# Termux snapshot
log "Capturing Termux files"
cp -r ~/.termux "$OUT/termux/" 2>/dev/null || true
cp ~/.bash_history ~/.bashrc "$OUT/termux/" 2>/dev/null || true
find "$HOME" -maxdepth 6 -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" -o -name "*.json" -o -name "*.md" \) 2>/dev/null | head -3000 | cpio -pdm "$OUT/termux/" 2>/dev/null || true

# Downloads
log "Capturing Downloads"
for d in /storage/emulated/0/Download /sdcard/Download; do
  [ -d "$d" ] && find "$d" -maxdepth 5 -type f \( -name "*.py" -o -name "*.pdf" -o -name "*.zip" -o -name "*.json" \) | cpio -pdm "$OUT/downloads/" 2>/dev/null || true
done

# Final archive
cd "$ROOT/raw_exports"
tar czf "gmail_METADATA_$TS.tar.gz" "gmail_METADATA_$TS"

SIZE=$(du -h "gmail_METADATA_$TS.tar.gz" | cut -f1)
FILES=$(tar tzf "gmail_METADATA_$TS.tar.gz" | wc -l)

log "GMAIL METADATA CLONE COMPLETE"
log "Archive : $ROOT/raw_exports/gmail_METADATA_$TS.tar.gz"
log "Size    : $SIZE"
log "Files   : $FILES"
log "Done. Sovereign vault secured."
