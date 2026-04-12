#!/data/data/com.termux/files/usr/bin/bash
# C25 OBSIDIAN AGENT
# Writes all pipeline outputs to Obsidian vault for tracking
OBSIDIAN_DIR="/sdcard/Documents/Obsidian"
C25_VAULT="$OBSIDIAN_DIR/Constellation25"
C25_HOME="$HOME/constellation25"
MANIFEST="$C25_HOME/logs/totalrecall_manifest.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }
sha() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

mkdir -p "$C25_VAULT/gamma" "$C25_VAULT/agents" \
         "$C25_VAULT/pipeline" "$C25_VAULT/evidence"

TITLE="${1:-Gamma Run}"
CONTENT="${2:-No content provided}"
CATEGORY="${3:-pipeline}"

NOTE_FILE="$C25_VAULT/$CATEGORY/$(date '+%Y-%m-%d')-${TITLE// /-}.md"
NOTE_SHA=$(sha "$TITLE$CONTENT$(ts)")

cat > "$NOTE_FILE" << NOTEEOF
# $TITLE
**Date:** $(ts)
**Operator:** u0_a510
**Category:** $CATEGORY
**SHA256:** $NOTE_SHA

## Content
$CONTENT

## Chain of Custody
- System: Constellation25 v25.0.0
- TotalRecall: SHA256 anchored
- Canonical: AI proposes. Only a human may execute.
NOTEEOF

echo "[$(ts)] [OBSIDIAN_AGENT] Note → $NOTE_FILE SHA256:$NOTE_SHA" \
  | tee -a "$MANIFEST"
