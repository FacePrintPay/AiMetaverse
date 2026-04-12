#!/data/data/com.termux/files/usr/bin/bash

echo "Starting PaTHos API Server..."

# Check if already running
if pgrep -f "PaTHos_API.py" > /dev/null; then
    echo "Server is already running!"
    echo "Run './stop_api.sh' to stop it first."
    exit 1
fi

# Start server in background
nohup python3 ~/PaTHos/api/PaTHos_API.py > ~/PaTHos/api.log 2>&1 &

# Wait for server to fully start
sleep 4

# Check if it started successfully
if pgrep -f "PaTHos_API.py" > /dev/null; then
    echo "✓ Server started successfully!"
    echo "  Local:   http://127.0.0.1:5000"
    echo "  Network: http://192.168.1.33:5000"
    echo ""
    echo "View logs: tail -f ~/PaTHos/api.log"
    echo "Test API: ./test_api.sh"
    echo "Stop server: ./stop_api.sh"
else
    echo "✗ Failed to start server. Check ~/PaTHos/api.log for errors"
    exit 1
fi
