#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="jupiter"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  AGENTS_UP=0
  for PID_FILE in "$C25/agents/"*.pid; do
    [ -f "$PID_FILE" ] || continue
    PID=$(cat "$PID_FILE")
    kill -0 "$PID" 2>/dev/null && AGENTS_UP=$((AGENTS_UP+1))
  done
  TASKS=$(find "$C25/tasks" -name "*.json" 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] ORCHESTRATION agents_up:$AGENTS_UP pending_tasks:$TASKS" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK agents:$AGENTS_UP" >> "$LOGS/jupiter.log"
  # Restart dead agents check
  for PID_FILE in "$C25/agents/"*.pid; do
    [ -f "$PID_FILE" ] || continue
    PID=$(cat "$PID_FILE")
    ANAME=$(basename "$PID_FILE" .pid)
    if ! kill -0 "$PID" 2>/dev/null; then
      echo "[$TS] [$NAME] RESTART_DETECTED dead_agent:$ANAME" >> "$LOGS/constellation25.log"
    fi
  done
  sleep 60
done
