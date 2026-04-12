#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="uranus"
API_DIR="$C25/api_results"
mkdir -p "$API_DIR"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for REQ in "$C25/tasks"/api_request_*.json; do
    [ -f "$REQ" ] || continue
    URL=$(python3 -c "import json; d=json.load(open('$REQ')); print(d.get('url',''))" 2>/dev/null)
    if [ -n "$URL" ]; then
      RESULT=$(curl -s --max-time 10 "$URL" 2>/dev/null)
      echo "$RESULT" > "$API_DIR/result_$(date +%s).json"
      echo "[$TS] [$NAME] API_CALL url:$URL" >> "$LOGS/constellation25.log"
      mv "$REQ" "$REQ.done"
    fi
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/uranus.log"
  sleep 60
done
