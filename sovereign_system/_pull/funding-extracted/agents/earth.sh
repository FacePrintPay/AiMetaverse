#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="earth"
mkdir -p "$C25/workspace"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  DISK=$(df -h "$HOME" | awk 'NR==2{print $4}')
  FILES=$(find "$C25" -type f 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] DISK_FREE:$DISK C25_FILES:$FILES" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/earth.log"
  sleep 60
done
