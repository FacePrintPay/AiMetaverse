#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

AGENT="$1"
TASK_FILE="$2"
TASK_ID=$(basename "$TASK_FILE" .json | cut -d_ -f2-)

OUT_DIR="$HOME/outputs/$AGENT"
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/$TASK_ID.md"

MESSAGE=$(jq -r '.message' "$TASK_FILE")

{
  echo "# SovereignGTP Task $TASK_ID"
  echo "**Agent:** $AGENT"
  echo "**Executed on-device:** $(date '+%F %H:%M:%S')"
  echo "**Termux sovereign mode:** ACTIVE"
  echo
  echo "### Original Prompt"
  echo "$MESSAGE"
  echo
  echo "### Full Response"
  echo "[Local LLM not configured yet — placeholder response]"
  echo
  echo "**Output written to:** $OUT_FILE"
} > "$OUT_FILE"

echo "[$(date '+%F %T')] Agent $AGENT wrote output → $OUT_FILE" >> "$HOME/logs/orchestrator/daemon.log"

exit 0
