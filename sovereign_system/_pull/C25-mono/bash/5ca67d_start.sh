#!/usr/bin/env bash
# 🌌 C25 Bridge Starter
PORT="${C25_PORT:-8080}"
while python3 -c "import socket;s=socket.socket();s.bind(('',$PORT));s.close()" 2>/dev/null; do PORT=$((PORT+1)); done
export C25_PORT=$PORT
echo "🌌 Starting bridge on port $PORT"
python3 "$(dirname "$0")/c25-bridge.py" &
echo $! > ~/.c25/bridge.pid
IP=$(ip addr show wlan0 2>/dev/null | grep inet | grep -v inet6 | awk '{print $2}' | cut -d/ -f1 || echo "127.0.0.1")
echo "✅ Bridge PID: $(cat ~/.c25/bridge.pid)"
echo "📱 Set TERMUX_BRIDGE to: http://$IP:$PORT"
