#!/data/data/com.termux/files/usr/bin/bash
# c25-launch - C25 Module
# Auto-scaffolded by Earth Agent
echo "🌟 c25-launch starting..."
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS connected"
echo "[c25-launch] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/c25-launch.log"
