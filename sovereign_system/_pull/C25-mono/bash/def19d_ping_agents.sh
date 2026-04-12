#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "📡 Pinging Planetary Agents..."
for agent in ./agents/*.sh; do
  [ "$agent" = "./agents/ping_agents.sh" ] && continue
  name=$(basename "$agent" .sh)
  log_file="logs/${name}_ping.log"
  nohup bash "$agent" > "$log_file" 2>&1 &
  echo "✅ $name launched — logging to $log_file"
done
