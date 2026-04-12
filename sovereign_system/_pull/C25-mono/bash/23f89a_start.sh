#!/data/data/com.termux/files/usr/bin/bash

# PaTHos API - Start Script
# Quick startup script for the Flask application

echo "Starting PaTHos API Server..."
echo ""

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo "Error: Python is not installed. Run setup.sh first."
    exit 1
fi

# Check if PaTHos_API.py exists
if [ ! -f "PaTHos_API.py" ]; then
    echo "Error: PaTHos_API.py not found in current directory."
    exit 1
fi

# Get local IP address
LOCAL_IP=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n1)

echo "Server will be accessible at:"
echo "  Local:   http://127.0.0.1:5000"
if [ -n "$LOCAL_IP" ]; then
    echo "  Network: http://${LOCAL_IP}:5000"
fi
echo ""
echo "Press CTRL+C to stop the server"
echo "=================================="
echo ""

# Start the Flask application
python PaTHos_API.py
