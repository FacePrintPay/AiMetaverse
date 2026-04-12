#!/data/data/com.termux/files/usr/bin/bash
# Constellation25 Production Start Script
# Sovereign Bash Orchestration
# Architect: Cygel White (#MrGGTP / TotalRecall)

set -e

BASE_DIR="$HOME/constellation25"
LOG_DIR="$BASE_DIR/logs"
TASK_DIR="$BASE_DIR/tasks"
RECALL_DIR="$HOME/TotalRecall/constellation25"

mkdir -p "$LOG_DIR" "$TASK_DIR" "$RECALL_DIR"

log_forensic() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/production.log"
    local hash=$(echo "$timestamp $level $message" | sha256sum | cut -d' ' -f1)
    echo "$hash  [$timestamp] [$level] $message" >> "$RECALL_DIR/blockchain_manifest.txt"
}

cleanup_previous_runs() {
    log_forensic "INFO" "Cleaning up previous agent processes..."
    pkill -f "-agent.sh" 2>/dev/null || true
    rm -f "$LOG_DIR"/*.pid 2>/dev/null || true
    sleep 2
    log_forensic "INFO" "Cleanup complete"
}

cleanup() {
    log_forensic "INFO" "Shutting down Constellation25..."
    pkill -f "-agent.sh" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

log_forensic "INFO" "=== Constellation25 Production Start ==="
log_forensic "INFO" "Base directory: $BASE_DIR"
log_forensic "INFO" "Agents directory: $BASE_DIR/agents"

cleanup_previous_runs

start_agent() {
    local agent_name="$1"
    local agent_script="$BASE_DIR/agents/${agent_name}-agent.sh"
    
    if [ -f "$agent_script" ]; then
        log_forensic "INFO" "Starting $agent_name agent..."
        bash "$agent_script" &
        local pid=$!
        echo "$pid" > "$LOG_DIR/${agent_name}.pid"
        log_forensic "INFO" "$agent_name agent started with PID $pid"
    else
        log_forensic "ERROR" "Agent script not found: $agent_script"
    fi
}

log_forensic "INFO" "Launching 25 planetary agents..."

agents="earth moon sun mercury venus mars jupiter saturn uranus neptune pluto cygnus orion andromeda pleiades sirius canismajor hydra vega polaris rigel capella altair deneb fomalhaut"

for agent in $agents; do
    start_agent "$agent"
    sleep 0.5
done

log_forensic "INFO" "All agents launched"
log_forensic "INFO" "Starting health monitoring..."

while true; do
    running=$(ps aux | grep agent.sh | grep -v grep | wc -l)
    log_forensic "INFO" "Health check: $running/25 agents running"
    
    if [ "$running" -lt 25 ]; then
        log_forensic "WARN" "Some agents stopped. Attempting restart..."
        for agent in $agents; do
            pid_file="$LOG_DIR/${agent}.pid"
            if [ -f "$pid_file" ]; then
                pid=$(cat "$pid_file")
                if ! kill -0 "$pid" 2>/dev/null; then
                    log_forensic "INFO" "Restarting $agent agent..."
                    start_agent "$agent"
                fi
            fi
        done
    fi
    
    sleep 60
done
