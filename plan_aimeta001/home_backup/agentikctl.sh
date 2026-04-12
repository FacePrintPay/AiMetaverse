#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${TASKS_BASE:-$HOME/tasks}"
LOGS="$BASE/logs"
WATCH_LOG="$LOGS/swarm_watch.log"
PID_FILE="$BASE/.swarm_watch.pid"
WATCHER="${WATCHER_PATH:-$HOME/swarm_watch.sh}"

mkdir -p "$BASE"/{incoming,processing,done,failed,running,logs,logs/agents}

status() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[✓] swarm_watch RUNNING pid=$(cat "$PID_FILE")"
  else
    echo "[i] swarm_watch NOT running"
  fi
  echo "[i] incoming=$(ls -1 "$BASE/incoming" 2>/dev/null | wc -l) processing=$(ls -1 "$BASE/processing" 2>/dev/null | wc -l) done=$(ls -1 "$BASE/done" 2>/dev/null | wc -l) failed=$(ls -1 "$BASE/failed" 2>/dev/null | wc -l)"
}

start() {
  if [ ! -f "$WATCHER" ]; then
    echo "[X] Missing watcher: $WATCHER"
    exit 1
  fi
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "[i] Already running pid=$(cat "$PID_FILE")"
    exit 0
  fi
  echo "[i] Starting watcher..."
  nohup "$WATCHER" >>"$WATCH_LOG" 2>&1 &
  echo "$!" > "$PID_FILE"
  echo "[✓] Started pid=$!"
}

stop() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    pid="$(cat "$PID_FILE")"
    echo "[i] Stopping pid=$pid..."
    kill "$pid" || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "[✓] Stopped"
  else
    echo "[i] Not running"
    rm -f "$PID_FILE" 2>/dev/null || true
  fi
}

logs() {
  touch "$WATCH_LOG"
  tail -n 80 -f "$WATCH_LOG"
}

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  status) status ;;
  logs) logs ;;
  *) echo "Usage: bash ~/agentikctl.sh {start|stop|status|logs}" ; exit 1 ;;
esac
