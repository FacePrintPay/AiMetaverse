#!/data/data/com.termux/files/usr/bin/bash

echo "Stopping PaTHos API Server..."

if pgrep -f "PaTHos_API.py" > /dev/null; then
    pkill -f "PaTHos_API.py"
    sleep 1
    echo "✓ Server stopped"
else
    echo "Server is not running"
fi
