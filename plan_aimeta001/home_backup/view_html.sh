#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

FILE="${1:-$HOME/outputs/web/agi-kre8tive/index.html}"
[ -f "$FILE" ] || { echo "Missing file: $FILE"; exit 1; }

# Termux:API command? (termux-open)
command -v termux-open >/dev/null 2>&1 || {
  echo "Install Termux:API app + package:"
  echo "  pkg install termux-api"
  exit 1
}

# Find a free port
PORT=8765
for p in 8765 8766 8767 9000 9100; do
  if ! ss -ltn 2>/dev/null | grep -q ":$p "; then PORT=$p; break; fi
done

DIR="$(cd "$(dirname "$FILE")" && pwd)"
BASE="$(basename "$FILE")"
PIDFILE="$HOME/.html_viewer.pid"
LOG="$HOME/.html_viewer.log"

# Stop old server if any
if [ -f "$PIDFILE" ] && ps -p "$(cat "$PIDFILE")" >/dev/null 2>&1; then
  kill "$(cat "$PIDFILE")" 2>/dev/null || true
  rm -f "$PIDFILE"
fi

# Start server from the file's directory
cd "$DIR"
nohup python -m http.server "$PORT" --bind 127.0.0.1 >"$LOG" 2>&1 &
echo $! > "$PIDFILE"

URL="http://127.0.0.1:$PORT/$BASE"
echo "Serving: $FILE"
echo "URL: $URL"

# Open in Termux (pick Termux once, then hit 'Always')
termux-open "$URL"
