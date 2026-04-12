#!/data/data/com.termux/files/usr/bin/bash
sleep 3
source /data/data/com.termux/files/home/.bashrc 2>/dev/null
termux-wake-lock
tmux start-server
tmux kill-session -t c25 2>/dev/null
tmux new-session -d -s c25 "cd /data/data/com.termux/files/home/constellation-25 && node server.js"
echo "C25 BOOTED" >> /data/data/com.termux/files/home/agent_logs/boot.log
