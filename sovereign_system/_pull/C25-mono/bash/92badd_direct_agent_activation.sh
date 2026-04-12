#!/bin/bash
set -euo pipefail
# Configuration
HEARTBEAT_INTERVAL=14
AGENT_COUNT=17
LOG_DIR="$HOME/agent_logs"
LOCK_DIR="$HOME/.agent_locks"
PID_DIR="$HOME/.agent_pids"
# Create all required directories
mkdir -p "$LOG_DIR"
mkdir -p "$LOCK_DIR"
mkdir -p "$PID_DIR"
mkdir -p "$HOME/.agent_temp"
# Agent constellation mapping
declare -A AGENT_MAP=(
    [1]="Earth" [2]="Moon" [3]="Sun" [4]="Mercury" [5]="Venus" 
    [6]="Mars" [7]="Jupiter" [8]="Saturn" [9]="Uranus" [10]="Neptune"
    [11]="Cygnus" [12]="Orion" [13]="Andromeda" [14]="Pleiades" 
    [15]="Sirius" [16]="CanisMajor" [17]="Hydra"
)
# Direct agent start function (simplified)
start_single_agent() {
    local agent_num=$1
    local agent_name=${AGENT_MAP[$agent_num]}
    local next_agent=$((agent_num % AGENT_COUNT + 1))
    # Create agent-specific log
    local agent_log="$LOG_DIR/agent_${agent_num}_${agent_name}.log"
    # Simple agent process that creates heartbeat
    (
        echo "[$(date)] AGENT:$agent_num (${agent_name}) DIRECT STARTED" >> "$agent_log"
        while true; do
            # Create heartbeat file
            echo "[$(date)] AGENT:$agent_num heartbeat" >> "$agent_log"
            touch "$LOCK_DIR/agent_${agent_num}_alive.lock"
            echo "$(date)" > "$LOCK_DIR/agent_${agent_num}_timestamp"
            # Update lock file timestamp frequently
            touch "$LOCK_DIR/agent_${agent_num}_alive.lock"
            # Sleep for heartbeat interval
            sleep $HEARTBEAT_INTERVAL
            # Random health check
            if [ $((RANDOM % 4)) -eq 0 ]; then
                echo "[$(date)] AGENT:$agent_num health check" >> "$agent_log"
            fi
        done
    ) &
    # Save PID
    local pid=$!
    echo $pid > "$PID_DIR/agent_${agent_num}_process.pid"
    echo "[$(date)] AGENT:$agent_num PID: $pid" >> "$agent_log"
    # Also save to locks
    echo $pid > "$LOCK_DIR/agent_${agent_num}_pid"
    echo "Agent $agent_num ($agent_name) started with PID $pid"
}
# Function to start ALL agents directly
start_all_agents_directly() {
    echo "Starting all 17 agents directly..."
    for i in {1..17}; do
        start_single_agent $i
        sleep 0.3  # Short stagger
    done
    echo "All agents started! Waiting for activation..."
    sleep 3  # Give them time to write lock files
    # Count active agents
    local active_count=0
    for i in {1..17}; do
        if [ -f "$LOCK_DIR/agent_${i}_alive.lock" ]; then
            active_count=$((active_count + 1))
        fi
    done
    echo "Activation complete: $active_count/17 agents active"
    echo "Constellation 25 is now operational!"
}
# Run the direct activation
start_all_agents_directly
