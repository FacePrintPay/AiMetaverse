#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="sol"
INFER="$C25/inference"
mkdir -p "$INFER"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for REQ in "$C25/tasks"/infer_*.json; do
    [ -f "$REQ" ] || continue
    PROMPT=$(python3 -c "import json; d=json.load(open('$REQ')); print(d.get('prompt',''))" 2>/dev/null)
    echo "[$TS] [$NAME] INFERENCE_REQUEST prompt_len:${#PROMPT}" >> "$LOGS/constellation25.log"
    # Write to inference queue for MCP pickup
    cp "$REQ" "$INFER/pending_$(date +%s).json"
    mv "$REQ" "$REQ.processing"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/sol.log"
  sleep 30
done
