#!/data/data/com.termux/files/usr/bin/bash
# Constellation25 Service Manager

BASE_DIR="$HOME/constellation25"
LOG_DIR="$BASE_DIR/logs"
PID_FILE="$LOG_DIR/orchestrator.pid"

start() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Already running (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    pkill -f "-agent.sh" 2>/dev/null || true
    rm -f "$LOG_DIR"/*.pid 2>/dev/null || true
    sleep 1
    
    nohup bash "$BASE_DIR/production-start.sh" > "$LOG_DIR/nohup.out" 2>&1 &
    echo $! > "$PID_FILE"
    
    echo "Started Constellation25 (PID: $(cat $PID_FILE))"
    sleep 3
    status
}

stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Not running (no PID file)"
        pkill -f "-agent.sh" 2>/dev/null || true
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        echo "Stopping orchestrator (PID: $pid)..."
        kill "$pid" 2>/dev/null
        sleep 2
        pkill -f "-agent.sh" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "Stopped"
    else
        echo "Process not found, cleaning up..."
        rm -f "$PID_FILE"
        pkill -f "-agent.sh" 2>/dev/null || true
    fi
}

status() {
    echo "=== Constellation25 Status ==="
    
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Orchestrator: Running (PID: $pid)"
        else
            echo "Orchestrator: Stale PID file"
        fi
    else
        echo "Orchestrator: Not running"
    fi
    
    local running=$(ps aux | grep agent.sh | grep -v grep | wc -l)
    echo "Agent processes: $running detected"
    
    if [ -f "$LOG_DIR/production.log" ]; then
        echo ""
        echo "Recent logs:"
        tail -3 "$LOG_DIR/production.log"
    fi
}

logs() {
    tail -f "$LOG_DIR/production.log" 2>/dev/null || echo "No log file"
}

case "${1:-status}" in
    start) start ;;
    stop) stop ;;
    restart) stop && sleep 2 && start ;;
    status) status ;;
    logs) logs ;;
    *) echo "Usage: $0 {start|stop|restart|status|logs}" ;;
esac
