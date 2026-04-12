#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "🌌 Constellation 25 • Local Server"
python3 -m http.server 8080 &
sleep 2
termux-open http://localhost:8080/constellation
echo "✅ Running: http://localhost:8080/constellation"
