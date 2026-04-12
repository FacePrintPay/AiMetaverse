#!/data/data/com.termux/files/usr/bin/bash
# tasker.sh - Constellation25 Task Queue Manager
set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/constellation25}"
TASKER_DIR="${TASKER_DIR:-$BASE_DIR/tasker}"
QUEUE_DIR="$TASKER_DIR/queue"
DONE_DIR="$TASKER_DIR/completed"
FAIL_DIR="$TASKER_DIR/failed"
AGENTS_DIR="${AGENTS_DIR:-$BASE_DIR/agents}"
TIMESTAMP="$(date -u)"

mkdir -p "$QUEUE_DIR" "$DONE_DIR" "$FAIL_DIR"

# Create a new task
create_task() {
  local agent="$1"
  local task="$2"
  local priority="${3:-normal}"
  local task_id="task_$(date +%s)_$$"
  local task_file="$QUEUE_DIR/${task_id}.json"
  
  cat > "$task_file" <<EOF
{
  "id": "$task_id",
  "agent": "$agent",
  "task": "$task",
  "priority": "$priority",
  "status": "queued",
  "created": "$TIMESTAMP"
}
EOF
  echo "[OK] Task created: $task_id"
  echo "$task_id"
}

# Process next task from queue
process_queue() {
  local task_file=$(ls -t "$QUEUE_DIR"/*.json 2>/dev/null | head -1 || true)
  if [[ -z "$task_file" ]]; then
    echo "[INFO] Queue empty"
    return 0
  fi
  
  local task_id=$(jq -r '.id' "$task_file")
  local agent=$(jq -r '.agent' "$task_file")
  local task=$(jq -r '.task' "$task_file")
  
  echo "[PROCESSING] $task_id -> $agent: $task"
  
  # Route to agent script if exists
  if [[ -x "$AGENTS_DIR/${agent}_agent.sh" ]]; then
    if "$AGENTS_DIR/${agent}_agent.sh" "$task"; then
      mv "$task_file" "$DONE_DIR/"
      echo "[DONE] $task_id completed"
    else
      mv "$task_file" "$FAIL_DIR/"
      echo "[FAILED] $task_id moved to failed"
    fi
  else
    echo "[WARN] Agent script not found: ${agent}_agent.sh"
    mv "$task_file" "$FAIL_DIR/"
  fi
}

# Main loop
case "${1:-}" in
  create) create_task "${2:-}" "${3:-}" "${4:-normal}" ;;
  process) process_queue ;;
  status) echo "Queue: $(ls "$QUEUE_DIR"/*.json 2>/dev/null | wc -l) pending" ;;
  *) echo "Usage: $0 {create|process|status} [args]" ;;
esac
