#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="cassiopeia"
REPORTS="$C25/reports"
mkdir -p "$REPORTS"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  AGENTS_UP=$(ls "$C25/agents/"*.pid 2>/dev/null | while read P; do PID=$(cat "$P"); kill -0 "$PID" 2>/dev/null && echo 1; done | wc -l)
  TASKS_PEND=$(find "$C25/tasks" -name "*.json" 2>/dev/null | wc -l)
  TASKS_DONE=$(find "$C25/tasks" -name "*.done" 2>/dev/null | wc -l)
  LOG_LINES=$(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)
  cat > "$REPORTS/status_report.txt" << REPORT
╔══════════════════════════════════════════╗
║  CONSTELLATION25 — STATUS REPORT        ║
╚══════════════════════════════════════════╝
  Time          : $TS
  Agents Up     : $AGENTS_UP / 25
  Tasks Pending : $TASKS_PEND
  Tasks Done    : $TASKS_DONE
  Log Lines     : $LOG_LINES
REPORT
  echo "[$TS] [$NAME] REPORT_GENERATED agents:$AGENTS_UP tasks_done:$TASKS_DONE" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/cassiopeia.log"
  sleep 300
done
