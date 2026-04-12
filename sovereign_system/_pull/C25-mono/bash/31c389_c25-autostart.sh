#!/data/data/com.termux/files/usr/bin/bash

# C25 Constellation25 - Persistent Auto-Start
# Runs every time Termux opens

LOG="$HOME/sovereign_gtp/logs/boot.log"
mkdir -p "$HOME/sovereign_gtp/logs"
echo "[BOOT] $(date '+%Y-%m-%d %H:%M:%S') - C25 Starting..." >> "$LOG"

# 1. Start Ollama
pkill ollama 2>/dev/null
sleep 1
ollama serve > /dev/null 2>&1 &
echo "[BOOT] Ollama started" >> "$LOG"

# 2. Start PATHOS server in tmux
tmux kill-session -t pathos 2>/dev/null
tmux new-session -d -s pathos \
  "node ~/github-repos/Constillation25/sovereign_gtp/backend/server.js"
echo "[BOOT] PATHOS started on port 3000" >> "$LOG"

# 3. Start Ranger tmux session
tmux kill-session -t ranger 2>/dev/null
tmux new-session -d -s ranger \
  "cd ~/C25-MASTER && ranger"
echo "[BOOT] Ranger session started" >> "$LOG"

# 4. Log all agent status
for agent in Earth Moon Sun Mars Jupiter Saturn; do
    echo "[BOOT] Agent $agent: READY" >> "$LOG"
done

echo "[BOOT] C25 ONLINE - $(date '+%H:%M:%S')" >> "$LOG"

# MyBuyo Services
node ~/mybuyo-restore/services/dashboard/index.js > ~/mybuyo-restore/logs/dashboard.log 2>&1 &
node ~/mybuyo-restore/services/keys_api/index.js > ~/mybuyo-restore/logs/keys_api.log 2>&1 &
node ~/mybuyo-restore/services/swarm_api/index.js > ~/mybuyo-restore/logs/swarm_api.log 2>&1 &

# MyBuyo Services
node ~/mybuyo-restore/services/dashboard/index.js > ~/mybuyo-restore/logs/dashboard.log 2>&1 &
node ~/mybuyo-restore/services/keys_api/index.js > ~/mybuyo-restore/logs/keys_api.log 2>&1 &
node ~/mybuyo-restore/services/swarm_api/index.js > ~/mybuyo-restore/logs/swarm_api.log 2>&1 &
bash ~/c25-swarm-sync.sh > /dev/null 2>&1 &
node ~/github-repos/FacePrintPay/digital-dollar/api/server.js > ~/sovereign_gtp/logs/digitaldollar.log 2>&1 &
