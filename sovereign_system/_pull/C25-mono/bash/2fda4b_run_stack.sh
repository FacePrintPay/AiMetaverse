#!/usr/bin/env bash
set -e

LOGDIR="$HOME/STACK/logs"
mkdir -p "$LOGDIR"

echo "🚀 STARTING FULL STACK"

node "$HOME/STACK/services/node_api/server.js" \
  > "$LOGDIR/node.log" 2>&1 &

python "$HOME/STACK/services/python_api/app.py" \
  > "$LOGDIR/python.log" 2>&1 &

echo "✅ STACK RUNNING"
echo "🔗 Node API    → http://127.0.0.1:3000"
echo "🔗 Python API  → http://127.0.0.1:8000"

wait
