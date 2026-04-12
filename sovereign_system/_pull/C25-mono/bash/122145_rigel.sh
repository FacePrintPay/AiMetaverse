#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="rigel"
CODEGEN="$C25/codegen"
mkdir -p "$CODEGEN"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for REQ in "$C25/tasks"/codegen_*.json; do
    [ -f "$REQ" ] || continue
    LANG=$(python3 -c "import json; d=json.load(open('$REQ')); print(d.get('lang','bash'))" 2>/dev/null)
    TASK=$(python3 -c "import json; d=json.load(open('$REQ')); print(d.get('task',''))" 2>/dev/null)
    echo "[$TS] [$NAME] CODEGEN lang:$LANG task:$TASK" >> "$LOGS/constellation25.log"
    mv "$REQ" "$REQ.done"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/rigel.log"
  sleep 60
done
