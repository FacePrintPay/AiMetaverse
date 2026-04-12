#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="draco"
AUTO="$C25/automations"
mkdir -p "$AUTO"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for AUTO_TASK in "$C25/tasks"/auto_*.json; do
    [ -f "$AUTO_TASK" ] || continue
    SCRIPT=$(python3 -c "import json; d=json.load(open('$AUTO_TASK')); print(d.get('script',''))" 2>/dev/null)
    if [ -f "$AUTO/$SCRIPT" ]; then
      bash "$AUTO/$SCRIPT" >> "$LOGS/draco_exec.log" 2>&1
      echo "[$TS] [$NAME] EXECUTED script:$SCRIPT" >> "$LOGS/constellation25.log"
    fi
    mv "$AUTO_TASK" "$AUTO_TASK.done"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/draco.log"
  sleep 60
done
