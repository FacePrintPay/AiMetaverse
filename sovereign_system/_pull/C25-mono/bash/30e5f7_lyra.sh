#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="lyra"
MEDIA="$C25/media"
mkdir -p "$MEDIA"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  MEDIA_COUNT=$(find "$MEDIA" -type f 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] MEDIA_STATUS files:$MEDIA_COUNT" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/lyra.log"
  sleep 120
done
