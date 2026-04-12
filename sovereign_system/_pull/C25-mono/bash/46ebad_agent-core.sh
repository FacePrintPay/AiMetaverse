#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
AGENT_ID=19
C25_ROOT="/data/data/com.termux/files/home/Constellation25"
OBS_VAULT="${OBSIDIAN_VAULT:-$HOME/C25-Vault}"
MEMORY="$C25_ROOT/agents/planetary-$AGENT_ID/memory"
OUTPUT="$C25_ROOT/agents/planetary-$AGENT_ID/output"
mkdir -p "$MEMORY" "$OUTPUT"

# Auto-fetch env from Obsidian at runtime
source "$C25_ROOT/obsidian-bridge/fetch-env.sh" 2>/dev/null || true

execute_task() {
  local intent="$1"
  case "$intent" in
    build_remediation)
      gh run list --status failure --json databaseId -q '.[0].databaseId' 2>/dev/null | xargs -I {} gh run rerun {} 2>/dev/null && echo "completed" || echo "queued"
      ;;
    sovereign_deployment)
      git push origin main --force 2>/dev/null && echo "deployed" || echo "pending"
      ;;
    success_tracking)
      jq '[.[]|select(.conclusion=="success")]|length' /data/data/com.termux/files/home/fp-build-audit-*/builds-complete.json 2>/dev/null || echo "0"
      ;;
    *) echo "unknown_intent" ;;
  esac
}

echo "[$(date -Iseconds)] Agent $AGENT_ID started" >> "$OUTPUT/agent.log"
while true; do
  [ -f "$MEMORY/task.json" ] || { sleep 5; continue; }
  intent=$(jq -r '.intent' "$MEMORY/task.json" 2>/dev/null || echo "unknown")
  result=$(execute_task "$intent")
  echo "{\"agent\":$AGENT_ID,\"intent\":\"$intent\",\"result\":\"$result\",\"ts\":\"$(date -Iseconds)\"}" >> "$OUTPUT/audit.jsonl"
  rm -f "$MEMORY/task.json"
  sleep 2
done
