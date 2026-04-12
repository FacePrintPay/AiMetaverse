#!/usr/bin/env bash
set -euo pipefail

# Extend PATH for your tools
export PATH="$PATH:$HOME/YesQuid:$HOME"

echo "[48] Stopping old orchestrators (if any)…"
pkill -f orchestrator.sh || true
sleep 2

echo "[48] Creating log directories…"
mkdir -p ~/sovereignvault/logs

echo "[48] Launching orchestrator…"
nohup bash ~/orchestrator.sh > ~/sovereignvault/logs/orch.log 2>&1 &
sleep 5

echo "[48] Starting SLOT 48 parallel tasks…"

MOVES=(
  "echo '[48] Running self-check…'; hostname; date"
  "echo '[48] Validating environment…'; ls -lah ~/"
  "echo '[48] Checking orchestrator log…'; head -20 ~/sovereignvault/logs/orch.log"
  "echo '[48] System load…'; uptime"
  "echo '[48] Process list…'; ps aux --sort=-%cpu | head -10"
  "echo '[48] Network check…'; ping -c 2 1.1.1.1"
  "echo '[48] Storage check…'; df -h"
  "echo '[48] Memory check…'; free -h"
  "echo '[48] Directory inventory…'; find ~/ -maxdepth 2 -type d"
  "echo '[48] Completed a full diagnostics pass'"
)

for move in "${MOVES[@]}"; do
  bash -c "$move" &
done

echo "[48] All diagnostics launched in parallel."
echo "[48] Live logs:"
echo "tail -f ~/sovereignvault/logs/orch.log"
