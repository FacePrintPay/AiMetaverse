#!/bin/bash
# REPO: aikre8tive | FILE: cpp_gateway/run_gateway.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

APP_DIR="$HOME/aikre8tive/cpp_gateway"
BIN="$APP_DIR/build/gateway"
LOGDIR="$HOME/aikre8tive/logs"
RUNDIR="$HOME/aikre8tive/run"

mkdir -p "$LOGDIR" "$RUNDIR"

# Build if binary missing
if [[ ! -x "$BIN" ]]; then
  echo "🔧 Building gateway (missing binary)..."
  cmake -S "$APP_DIR" -B "$APP_DIR/build"
  cmake --build "$APP_DIR/build" -j
fi

# Launch and record PID
bash -lc "$BIN >> \"$LOGDIR/gateway.out.log\" 2>> \"$LOGDIR/gateway.err.log\" & echo \$! > \"$RUNDIR/gateway.pid\""
echo "🌠 Gateway started (pid \$(cat \"$RUNDIR/gateway.pid\")) → http://127.0.0.1:8080"
