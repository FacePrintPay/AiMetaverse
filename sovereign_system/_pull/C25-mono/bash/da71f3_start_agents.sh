#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🚀 Planetary Agents Swarm Launcher (v2)
# Commander: #MrGGTP
# Location: /data/data/com.termux/files/home
# ============================================

AGENTS=(Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto Luna \
Ceres Haumea Makemake Eris Io Europa Ganymede Callisto Titan Enceladus Triton \
Charon Phobos Deimos)

LOG_DIR="$HOME/logs/agents"
mkdir -p "$LOG_DIR"

echo "======================================"
echo "🚀 ULTIMATE 1BASH DEPLOY ALL 🚀"
echo "Commander: #MrGGTP"
echo "Timestamp: $(date)"
echo "======================================"
echo "🧹 Phase 1: Process Cleanup"

# Kill any existing agent processes to prevent duplicates
pkill -f "planetary_agents" 2>/dev/null && echo "🔪 Old agents terminated."
sleep 1

echo "======================================"
echo "🛰 Phase 2: Agent Launch"
echo "======================================"

for A in "${AGENTS[@]}"; do
  echo "🚀 Launching $A agent..."
  nohup python3 "$HOME/agents/planetary_agents.py" --name "$A" \
    > "$LOG_DIR/${A}.log" 2>&1 &
  sleep 0.5
done

echo "======================================"
echo "✅ 25 Agents Online."
echo "Logs: $LOG_DIR/<Agent>.log"
echo "======================================"
