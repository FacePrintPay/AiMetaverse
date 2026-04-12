#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="neptune"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  NET=$(curl -s --max-time 3 https://1.1.1.1 > /dev/null 2>&1 && echo ONLINE || echo OFFLINE)
  IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo unknown)
  echo "[$TS] [$NAME] NETWORK status:$NET ip:$IP" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:$NET" >> "$LOGS/neptune.log"
  sleep 120
done
