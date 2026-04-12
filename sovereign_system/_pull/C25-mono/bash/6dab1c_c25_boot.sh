#!/data/data/com.termux/files/usr/bin/bash
# C25 Auto-Boot — runs on every Termux start
sleep 5  # wait for system

# Source bashrc
source /data/data/com.termux/files/home/.bashrc 2>/dev/null

# Start PathFinder
source /data/data/com.termux/files/home/constellation-25/pathfinder.sh 2>/dev/null

# Start C25 server in tmux
tmux kill-session -t c25 2>/dev/null
tmux new-session -d -s c25 "cd /data/data/com.termux/files/home/constellation-25 && npm start"

# Start TotalRecall WebSocket in tmux
tmux kill-session -t recall 2>/dev/null
tmux new-session -d -s recall "node /data/data/com.termux/files/home/constellation-25/totalrecall_ws.js"

# Log boot to Memoria
sqlite3 /data/data/com.termux/files/home/constellation-25/memoria.db "INSERT INTO logs (agent,event,detail) VALUES ('Boot','AUTO_BOOT','2026-03-12T14:05:25Z');"

# Run inventory on boot
bash /data/data/com.termux/files/home/constellation-25/c25_inventory.sh > /dev/null 2>&1 &

echo "C25 BOOT COMPLETE" >> /data/data/com.termux/files/home/agent_logs/boot.log
