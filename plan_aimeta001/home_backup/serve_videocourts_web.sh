#!/data/data/com.termux/files/usr/bin/bash
# Serve VideoCourts web over HTTP so you can view it in a browser

set -euo pipefail

ROOT="$HOME/videocourts-justice-stack/apps/videocourts-web"
PORT="${1:-8085}"

cd "$ROOT"

echo ""
echo "🌐 Serving VideoCourts web from:"
echo "   $ROOT"
echo "   http://127.0.0.1:$PORT"
echo ""
echo "Tip: In another app, open the browser to that URL."
echo ""

python -m http.server "$PORT"
