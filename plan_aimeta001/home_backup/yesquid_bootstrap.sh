#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "=== YesQuidPro Sovereign Bootstrap ==="

HOME_DIR="$(realpath ~)"
YESQUID_DIR="$HOME_DIR/YesQuid"

# Respect SovereignVault/env.sh if present
if [ -f "$HOME_DIR/SovereignVault/env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME_DIR/SovereignVault/env.sh"
fi

TASKS_ROOT="${TASKS_ROOT:-$HOME_DIR/tasks}"
AGENTS_DIR="${AGENTS_DIR:-$HOME_DIR/agents}"
LOGS_ROOT="${LOGS_ROOT:-$HOME_DIR/logs}"

mkdir -p "$YESQUID_DIR"
mkdir -p "$TASKS_ROOT/incoming" "$TASKS_ROOT/processing" "$TASKS_ROOT/completed" "$TASKS_ROOT/failed"
mkdir -p "$AGENTS_DIR"
mkdir -p "$LOGS_ROOT/orchestrator" "$LOGS_ROOT/agents"

echo "HOME_DIR   = $HOME_DIR"
echo "TASKS_ROOT = $TASKS_ROOT"
echo "AGENTS_DIR = $AGENTS_DIR"
echo "LOGS_ROOT  = $LOGS_ROOT"
echo ""

# ---------------------------------------------------------------------
# 1. send_task.sh
# ---------------------------------------------------------------------
SEND_TASK="$HOME_DIR/send_task.sh"

cat > "$SEND_TASK" << 'SEND_EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Load SovereignVault env if available
if [ -f "$HOME/SovereignVault/env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/SovereignVault/env.sh"
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <agent_name> \"message...\""
  echo "Example: $0 agent_valuation \"Debug test — confirm swarm is alive\""
  exit 1
fi

AGENT="$1"
shift
MESSAGE="$*"

TASKS_ROOT="${TASKS_ROOT:-$HOME/tasks}"
INCOMING="${TASKS_ROOT}/incoming"

mkdir -p "$INCOMING"

TASK_ID="$(date +%s%N)"

cat > "${INCOMING}/task_${TASK_ID}.json" <<JSON
{
  "task_id": "${TASK_ID}",
  "agent": "${AGENT}",
  "message": "${MESSAGE}",
  "timestamp": "$(date -Iseconds)",
  "status": "pending"
}
JSON

echo "Task sent -> ${AGENT}: ${MESSAGE}"
echo "Task ID: ${TASK_ID}"
SEND_EOF

chmod +x "$SEND_TASK"
echo "send_task.sh installed at $SEND_TASK"

# ---------------------------------------------------------------------
# 2. orchestrator.sh
# ---------------------------------------------------------------------
ORCH="$HOME_DIR/orchestrator.sh"

cat > "$ORCH" << 'ORCH_EOF'
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
ORCH_EOF

chmod +x "$ORCH"
echo "orchestrator.sh installed at $ORCH"

# ---------------------------------------------------------------------
# 3. Minimal agent_valuation (baseline self-heal agent)
# ---------------------------------------------------------------------
AGENT_VAL="$AGENTS_DIR/agent_valuation.sh"

if [ ! -x "$AGENT_VAL" ]; then
  cat > "$AGENT_VAL" << 'AGENT_EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

task_file="$1"

ts="$(date '+%Y-%m-%d %H:%M:%S')"
msg="$(jq -r '.message // ""' "$task_file")"

echo "$ts [agent_valuation] handled task."
echo "Message: $msg"
AGENT_EOF

  chmod +x "$AGENT_VAL"
  echo "agent_valuation installed at $AGENT_VAL"
else
  echo "agent_valuation already exists (kept)"
fi

# ---------------------------------------------------------------------
# 4. sgtp CLI
# ---------------------------------------------------------------------
SGTP_CLI="$YESQUID_DIR/sgtp"

cat > "$SGTP_CLI" << 'CLI_EOF'
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
CLI_EOF

chmod +x "$SGTP_CLI"
echo "sgtp CLI installed at $SGTP_CLI"

# Ensure CLI on PATH for future shells
if ! grep -q 'YesQuid' "$HOME_DIR/.bashrc" 2>/dev/null; then
  echo 'export PATH="$PATH:$HOME/YesQuid"' >> "$HOME_DIR/.bashrc"
fi

# ---------------------------------------------------------------------
# 5. Supervity-style 1000-task seeder
# ---------------------------------------------------------------------
SEED="$YESQUID_DIR/supervity_seed_1000.sh"

cat > "$SEED" << 'SEED_EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HOME_DIR="$(realpath ~)"

if [ -f "$HOME_DIR/SovereignVault/env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME_DIR/SovereignVault/env.sh"
fi

TASKS_ROOT="${TASKS_ROOT:-$HOME_DIR/tasks}"
AGENTS_DIR="${AGENTS_DIR:-$HOME_DIR/agents}"
LOGS_ROOT="${LOGS_ROOT:-$HOME_DIR/logs}"

mkdir -p "$TASKS_ROOT/incoming" "$TASKS_ROOT/processing" "$TASKS_ROOT/completed" "$TASKS_ROOT/failed"
mkdir -p "$AGENTS_DIR"
mkdir -p "$LOGS_ROOT/agents"

SEND_TASK="$HOME_DIR/send_task.sh"
if [ ! -x "$SEND_TASK" ]; then
  echo "send_task.sh not found or not executable at $SEND_TASK"
  exit 1
fi

AGENTS=(
  agent_valuation
  agent_performance
  agent_observability
  agent_roi
  agent_governance
  agent_security
  agent_compliance
  agent_anomaly
  agent_banking
  agent_insurance
  agent_healthcare
  agent_government
  agent_manufacturing
  agent_hospitality
  agent_university
  agent_ap
  agent_ar
  agent_procurement
  agent_sales_enablement
  agent_hr_ops
  agent_it_support
  agent_customer_support
  agent_recruiter
)

DOMAINS=(
  landing-page-rebuild
  compliance-audit
  investor-materials-cicd
  county-pilot-deployment
  marketing-automation
  backend-api-development
  database-schema-migrations
  testing-qa-automation
  devops-infrastructure
  security-penetration-testing
)

for ag in "${AGENTS[@]}"; do
  script="$AGENTS_DIR/${ag}.sh"
  if [ ! -x "$script" ]; then
    cat > "$script" << 'AGENTEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

task_file="$1"
agent_name="$(basename "$0" .sh)"
ts="$(date '+%Y-%m-%d %H:%M:%S')"
msg="$(jq -r '.message // ""' "$task_file")"

echo "$ts [$agent_name] handled task."
echo "Message: $msg"
AGENTEOF
    chmod +x "$script"
  fi
done

NUM_TASKS=1000

echo "Seeding $NUM_TASKS tasks into $TASKS_ROOT/incoming"

i=1
while [ "$i" -le "$NUM_TASKS" ]; do
  ag_index=$(( (i - 1) % ${#AGENTS[@]} ))
  dm_index=$(( (i - 1) % ${#DOMAINS[@]} ))

  agent_name="${AGENTS[$ag_index]}"
  domain_name="${DOMAINS[$dm_index]}"

  message="Supervity seed #$i :: domain=${domain_name} :: agent=${agent_name} :: build performance, observability, ROI, governance, and compliance views for this slice."

  "$SEND_TASK" "$agent_name" "$message" >/dev/null 2>&1

  if [ $((i % 50)) -eq 0 ]; then
    echo "Seeded $i / $NUM_TASKS tasks..."
  fi

  i=$((i + 1))
done

echo "Finished seeding $NUM_TASKS tasks."
SEED_EOF

chmod +x "$SEED"
echo "supervity_seed_1000.sh installed at $SEED"

echo ""
echo "Bootstrap complete."
echo "In this shell, run:"
echo "  export PATH=\"\$PATH:\$HOME/YesQuid\""
echo "Then:"
echo "  sgtp start"
echo "  sgtp task agent_valuation \"Debug test — confirm swarm is alive\""
echo "  sgtp status"
echo "To seed the 1000-task Supervity backlog:"
echo "  bash \$HOME/YesQuid/supervity_seed_1000.sh"
