#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="orion"
QUEUE="$C25/tasks"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  PENDING=$(find "$QUEUE" -name "*.json" 2>/dev/null | wc -l)
  DONE=$(find "$QUEUE" -name "*.done" 2>/dev/null | wc -l)
  OLDEST=""
  if [ "$PENDING" -gt 0 ]; then
    OLDEST=$(ls -t "$QUEUE"/*.json 2>/dev/null | tail -1)
  fi
  echo "[$TS] [$NAME] QUEUE pending:$PENDING done:$DONE oldest:$(basename ${OLDEST:-none})" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK pending:$PENDING" >> "$LOGS/orion.log"
  sleep 45
done
