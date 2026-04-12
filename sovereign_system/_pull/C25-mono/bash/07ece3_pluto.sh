#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="pluto"
ARCHIVE="$C25/archive"
mkdir -p "$ARCHIVE"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  DATE=$(date '+%Y%m%d')
  BACKUP="$ARCHIVE/c25_backup_$DATE.tar.gz"
  if [ ! -f "$BACKUP" ]; then
    tar -czf "$BACKUP" -C "$HOME" constellation25/logs constellation25/tasks 2>/dev/null
    SIZE=$(du -h "$BACKUP" 2>/dev/null | cut -f1)
    SHA=$(sha256sum "$BACKUP" | cut -d' ' -f1)
    echo "[$TS] [$NAME] BACKUP_CREATED file:$BACKUP size:$SIZE sha256:$SHA" >> "$LOGS/constellation25.log"
    echo "[$TS] [PLUTO] [BACKUP] SHA256:$SHA file:$BACKUP" >> "$LOGS/totalrecall_manifest.log"
  fi
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/pluto.log"
  sleep 3600
done
