#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="mars"
QUEUE="$C25/tasks"; BUILD="$C25/builds"
mkdir -p "$BUILD"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for TASK in "$QUEUE"/task_*_mars.json; do
    [ -f "$TASK" ] || continue
    ACTION=$(python3 -c "import json,sys; d=json.load(open('$TASK')); print(d.get('action',''))" 2>/dev/null)
    TARGET=$(python3 -c "import json,sys; d=json.load(open('$TASK')); print(d.get('target',''))" 2>/dev/null)
    echo "[$TS] [$NAME] EXECUTING action:$ACTION target:$TARGET" >> "$LOGS/constellation25.log"
    mv "$TASK" "$TASK.done"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/mars.log"
  sleep 45
done
