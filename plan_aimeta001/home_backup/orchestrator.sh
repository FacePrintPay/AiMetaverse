#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HOME_DIR="$(realpath ~)"

# Respect env if available
if [ -f "$HOME_DIR/SovereignVault/env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME_DIR/SovereignVault/env.sh"
fi

TASKS_ROOT="${TASKS_ROOT:-$HOME_DIR/tasks}"
INCOMING="$TASKS_ROOT/incoming"
PROCESSING="$TASKS_ROOT/processing"
COMPLETED="$TASKS_ROOT/completed"
FAILED="$TASKS_ROOT/failed"

AGENTS_DIR="${AGENTS_DIR:-$HOME_DIR/agents}"
LOGS_ROOT="${LOGS_ROOT:-$HOME_DIR/logs}"
LOGS_DIR="$LOGS_ROOT/orchestrator"
PID_FILE="$LOGS_DIR/orchestrator.pid"
POLL_INTERVAL="${ORCHESTRATOR_POLL_INTERVAL:-2}"

mkdir -p "$INCOMING" "$PROCESSING" "$COMPLETED" "$FAILED"
mkdir -p "$AGENTS_DIR"
mkdir -p "$LOGS_DIR"

log() {
  echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] $*" | tee -a "$LOGS_DIR/daemon.log"
}

dispatch_agent() {
  local agent="$1"
  local task_file="$2"
  local script="$AGENTS_DIR/${agent}.sh"

  if [ ! -x "$script" ]; then
    log "Agent script not found or not executable: $script"
    return 1
  fi

  if "$script" "$task_file" >> "$LOGS_DIR/agent_${agent}.log" 2>&1; then
    return 0
  else
    log "Agent $agent crashed (see $LOGS_DIR/agent_${agent}.log)"
    return 1
  fi
}

process_task() {
  local f="$1"
  local base
  base="$(basename "$f")"

  mv "$f" "$PROCESSING/$base"

  local task="$PROCESSING/$base"
  local id
  local agent

  id="$(jq -r '.task_id // "unknown"' "$task")"
  agent="$(jq -r '.agent // "unknown"' "$task")"

  if [ -z "$agent" ] || [ "$agent" = "null" ] || [ "$agent" = "unknown" ]; then
    log "No valid agent for task $id"
    mv "$task" "$FAILED/$base"
    return
  fi

  log "Dispatching task $id -> $agent"

  if dispatch_agent "$agent" "$task"; then
    log "Completed task $id"
    mv "$task" "$COMPLETED/$base"
  else
    log "Failed task $id"
    mv "$task" "$FAILED/$base"
  fi
}

run_loop() {
  log "SovereignGTP Orchestrator ONLINE (PID $$)"
  log "Watching: $INCOMING"

  while true; do
    shopt -s nullglob
    for t in "$INCOMING"/task_*.json; do
      [ -f "$t" ] && process_task "$t"
    done
    shopt -u nullglob
    sleep "$POLL_INTERVAL"
  done
}

start_orch() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null || echo "")"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "Orchestrator already running (PID $pid)"
      return
    fi
  fi

  nohup "$0" _run >> "$LOGS_DIR/daemon.log" 2>&1 &
  echo $! > "$PID_FILE"
  echo "Orchestrator started (PID $(cat "$PID_FILE"))"
}

stop_orch() {
  if [ ! -f "$PID_FILE" ]; then
    echo "No PID file. Orchestrator may not be running."
    return
  fi

  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || echo "")"
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
    echo "Orchestrator stopped (PID $pid)"
  else
    echo "Orchestrator not running."
  fi
  rm -f "$PID_FILE"
}

status_orch() {
  echo "Pending:    $(find "$INCOMING"   -maxdepth 1 -name 'task_*.json' 2>/dev/null | wc -l)"
  echo "Processing: $(find "$PROCESSING" -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
  echo "Completed:  $(find "$COMPLETED"  -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
  echo "Failed:     $(find "$FAILED"     -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
}

case "${1:-}" in
  start)
    start_orch
    ;;
  stop)
    stop_orch
    ;;
  status)
    status_orch
    ;;
  _run)
    run_loop
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
