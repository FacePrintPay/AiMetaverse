#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="luna"
MEMORY="$C25/memory"
mkdir -p "$MEMORY"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  # Snapshot recent context
  RECENT=$(tail -50 "$LOGS/constellation25.log" 2>/dev/null)
  echo "$RECENT" > "$MEMORY/context_snapshot.txt"
  TASKS_DONE=$(find "$C25/tasks" -name "*.done" 2>/dev/null | wc -l)
  TASKS_PEND=$(find "$C25/tasks" -name "*.json" 2>/dev/null | wc -l)
  cat > "$MEMORY/state.json" << JSON
{
  "timestamp": "$TS",
  "tasks_done": $TASKS_DONE,
  "tasks_pending": $TASKS_PEND,
  "log_lines": $(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)
}
JSON
  echo "[$TS] [$NAME] MEMORY_UPDATED tasks_done:$TASKS_DONE tasks_pending:$TASKS_PEND" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/luna.log"
  sleep 90
done
