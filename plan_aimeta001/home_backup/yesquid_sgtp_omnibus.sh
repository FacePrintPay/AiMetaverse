#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "=== YesQuid SovereignGTP Omnibus Bootstrap ==="

HOME_DIR="$(realpath ~)"

# ---------------------------------------------------------------------
# 1. Core dirs (YesQuid-style layout)
# ---------------------------------------------------------------------
YESQUID_DIR="$HOME_DIR/YesQuid"
SOV_ENV_DIR="$HOME_DIR/SovereignVault"
TASKS_ROOT_DEFAULT="$HOME_DIR/tasks"
AGENTS_DIR_DEFAULT="$HOME_DIR/agents"
LOGS_ROOT_DEFAULT="$HOME_DIR/logs"
OUTPUTS_ROOT_DEFAULT="$HOME_DIR/outputs"

mkdir -p "$YESQUID_DIR"
mkdir -p "$SOV_ENV_DIR"

mkdir -p "$TASKS_ROOT_DEFAULT"/{incoming,processing,completed,failed}
mkdir -p "$AGENTS_DIR_DEFAULT"
mkdir -p "$LOGS_ROOT_DEFAULT"/{orchestrator,agents}
mkdir -p "$OUTPUTS_ROOT_DEFAULT"

echo "✓ Core directories ensured"

# ---------------------------------------------------------------------
# 2. SovereignVault env (only create if missing)
# ---------------------------------------------------------------------
ENV_FILE="$SOV_ENV_DIR/env.sh"

if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" << 'ENVEOF'
#!/data/data/com.termux/files/usr/bin/bash

# SovereignVault Environment (Minimal Core)
export TASKS_ROOT="$HOME/tasks"
export OUTPUTS_ROOT="$HOME/outputs"
export LOGS_ROOT="$HOME/logs"

mkdir -p "$TASKS_ROOT"/{incoming,processing,completed,failed}
mkdir -p "$OUTPUTS_ROOT"
mkdir -p "$LOGS_ROOT"/{orchestrator,agents}

echo "SovereignVault env loaded:"
echo "  TASKS_ROOT   = $TASKS_ROOT"
echo "  OUTPUTS_ROOT = $OUTPUTS_ROOT"
echo "  LOGS_ROOT    = $LOGS_ROOT"
ENVEOF
  chmod +x "$ENV_FILE"
  echo "✓ Created minimal SovereignVault env at $ENV_FILE"
else
  echo "• Existing env.sh detected at $ENV_FILE (left in place)"
fi

# Load env so TASKS_ROOT/LOGS_ROOT are available
# shellcheck source=/dev/null
source "$ENV_FILE"

# Fallbacks if env.sh didn't define them
TASKS_ROOT="${TASKS_ROOT:-$TASKS_ROOT_DEFAULT}"
AGENTS_DIR="${AGENTS_DIR:-$AGENTS_DIR_DEFAULT}"
LOGS_ROOT="${LOGS_ROOT:-$LOGS_ROOT_DEFAULT}"

mkdir -p "$TASKS_ROOT"/{incoming,processing,completed,failed}
mkdir -p "$AGENTS_DIR"
mkdir -p "$LOGS_ROOT"/{orchestrator,agents}

INCOMING="$TASKS_ROOT/incoming"
PROCESSING="$TASKS_ROOT/processing"
COMPLETED="$TASKS_ROOT/completed"
FAILED="$TASKS_ROOT/failed"
ORCH_LOG_DIR="$LOGS_ROOT/orchestrator"

echo "TASKS_ROOT = $TASKS_ROOT"
echo "AGENTS_DIR = $AGENTS_DIR"
echo "LOGS_ROOT  = $LOGS_ROOT"

# ---------------------------------------------------------------------
# 3. send_task.sh (idempotent overwrite; this is stable)
# ---------------------------------------------------------------------
SEND_TASK="$HOME_DIR/send_task.sh"

cat > "$SEND_TASK" << 'SENDEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Send a task into the SovereignGTP queue

# Load environment
if [ -f "$HOME/SovereignVault/env.sh" ]; then
  # shellcheck source=/dev/null
  source "$HOME/SovereignVault/env.sh"
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <agent_name> \"message...\""
  echo "Example: $0 agent_valuation \"Debug test — confirm swarm is alive\""
  exit 1
fi

AGENT="$1"
shift
MESSAGE="$*"

TASK_ID=$(date +%s%N)

TASKS_ROOT="${TASKS_ROOT:-$HOME/tasks}"
INCOMING="${TASKS_ROOT}/incoming"

mkdir -p "$INCOMING"

cat > "${INCOMING}/task_${TASK_ID}.json" <<JSON
{
  "task_id": "${TASK_ID}",
  "agent": "${AGENT}",
  "message": "${MESSAGE}",
  "timestamp": "$(date -Iseconds)",
  "status": "pending"
}
JSON

echo "Task sent → ${AGENT}: ${MESSAGE}"
echo "Task ID: ${TASK_ID}"
SENDEOF

chmod +x "$SEND_TASK"
echo "✓ send_task.sh installed at $SEND_TASK"

# ---------------------------------------------------------------------
# 4. Orchestrator (clean, no emojis, no weird chars)
# ---------------------------------------------------------------------
ORCH="$HOME_DIR/orchestrator.sh"
PID_FILE="$HOME_DIR/.sgtp_orchestrator.pid"
ORCH_LOG="$ORCH_LOG_DIR/daemon.log"

cat > "$ORCH" << 'ORCHEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HOME_DIR="$(realpath ~)"

# Load env if available
if [ -f "$HOME_DIR/SovereignVault/env.sh" ]; then
  # shellcheck source=/dev/null
  source "$HOME_DIR/SovereignVault/env.sh"
fi

TASKS_ROOT="${TASKS_ROOT:-$HOME_DIR/tasks}"
AGENTS_DIR="${AGENTS_DIR:-$HOME_DIR/agents}"
LOGS_ROOT="${LOGS_ROOT:-$HOME_DIR/logs}"

INCOMING="$TASKS_ROOT/incoming"
PROCESSING="$TASKS_ROOT/processing"
COMPLETED="$TASKS_ROOT/completed"
FAILED="$TASKS_ROOT/failed"
ORCH_LOG_DIR="$LOGS_ROOT/orchestrator"
PID_FILE="$HOME_DIR/.sgtp_orchestrator.pid"
POLL_INTERVAL="${ORCHESTRATOR_POLL_INTERVAL:-2}"

mkdir -p "$INCOMING" "$PROCESSING" "$COMPLETED" "$FAILED" "$AGENTS_DIR" "$ORCH_LOG_DIR"

log() {
  echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] $1" | tee -a "$ORCH_LOG_DIR/daemon.log"
}

dispatch_agent() {
  local agent="$1"
  local task_file="$2"
  local script="$AGENTS_DIR/${agent}.sh"

  if [ ! -x "$script" ]; then
    log "Agent script not found: $script"
    return 1
  fi

  if "$script" "$task_file" >> "$ORCH_LOG_DIR/agent_${agent}.log" 2>&1; then
    return 0
  else
    log "Agent crashed: $agent"
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
  id=$(jq -r .task_id "$task")
  local agent
  agent=$(jq -r .agent "$task")

  if [ -z "$agent" ] || [ "$agent" = "null" ]; then
    log "No agent for task $id"
    mv "$task" "$FAILED/$base"
    return
  fi

  log "Dispatching task $id to $agent"

  if dispatch_agent "$agent" "$task"; then
    mv "$task" "$COMPLETED/$base"
    log "Completed task $id"
  else
    mv "$task" "$FAILED/$base"
    log "Failed task $id"
  fi
}

run() {
  log "Orchestrator running (PID $$)"
  while true; do
    for t in "$INCOMING"/task_*.json; do
      [ -f "$t" ] && process_task "$t"
    done
    sleep "$POLL_INTERVAL"
  done
}

case "${1:-}" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Orchestrator already running (PID $(cat "$PID_FILE"))"
      exit 0
    fi
    nohup "$0" _run >> "$ORCH_LOG_DIR/daemon.log" 2>&1 &
    echo $! > "$PID_FILE"
    echo "Started PID $(cat "$PID_FILE")"
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      kill "$(cat "$PID_FILE")" 2>/dev/null || true
      rm -f "$PID_FILE"
      echo "Stopped orchestrator"
    else
      echo "No PID file; orchestrator may not be running"
    fi
    ;;
  status)
    echo "Pending:    $(find "$INCOMING"   -maxdepth 1 -name 'task_*.json' 2>/dev/null | wc -l)"
    echo "Processing: $(find "$PROCESSING" -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
    echo "Completed:  $(find "$COMPLETED"  -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
    echo "Failed:     $(find "$FAILED"     -maxdepth 1 -name '*.json'      2>/dev/null | wc -l)"
    ;;
  _run)
    run
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
ORCHEOF

chmod +x "$ORCH"
echo "✓ Orchestrator installed at $ORCH"

# ---------------------------------------------------------------------
# 5. Minimal working agent_valuation (for end-to-end test)
# ---------------------------------------------------------------------
AGENT_VAL="$AGENTS_DIR/agent_valuation.sh"

cat > "$AGENT_VAL" << 'AGENTEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

task_file="$1"

ts="$(date '+%Y-%m-%d %H:%M:%S')"
msg="$(jq -r .message "$task_file")"

echo "$ts agent_valuation handled task."
echo "Message: $msg"
AGENTEOF

chmod +x "$AGENT_VAL"
echo "✓ agent_valuation installed at $AGENT_VAL"

# ---------------------------------------------------------------------
# 6. sgtp CLI (YesQuid front door)
# ---------------------------------------------------------------------
SGTP_CLI="$YESQUID_DIR/sgtp"

cat > "$SGTP_CLI" << 'CLIEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HOME_DIR="$(realpath ~)"

case "${1:-}" in
  task)
    shift
    "$HOME_DIR/send_task.sh" "$@"
    ;;
  status)
    "$HOME_DIR/orchestrator.sh" status
    ;;
  start)
    "$HOME_DIR/orchestrator.sh" start
    ;;
  stop)
    "$HOME_DIR/orchestrator.sh" stop
    ;;
  *)
    echo "Usage:"
    echo "  sgtp task <agent> \"message...\""
    echo "  sgtp status"
    echo "  sgtp start"
    echo "  sgtp stop"
    exit 1
    ;;
esac
CLIEOF

chmod +x "$SGTP_CLI"

# Ensure CLI on PATH (idempotent)
if ! grep -q 'YesQuid' "$HOME_DIR/.bashrc" 2>/dev/null; then
  echo 'export PATH="$PATH:$HOME/YesQuid"' >> "$HOME_DIR/.bashrc"
fi

echo "✓ sgtp CLI installed at $SGTP_CLI (and added to PATH)"

echo "=== Omnibus bootstrap complete ==="
echo "Next steps (new shell):"
echo "  1) source ~/.bashrc"
echo "  2) sgtp start"
echo "  3) sgtp task agent_valuation \"Debug test — confirm swarm is alive\""
echo "  4) sgtp status"
