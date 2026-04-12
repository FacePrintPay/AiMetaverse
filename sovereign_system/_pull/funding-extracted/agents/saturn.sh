#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="saturn"
MANIFEST="$LOGS/totalrecall_manifest.log"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  LOG_SIZE=$(wc -c < "$LOGS/constellation25.log" 2>/dev/null || echo 0)
  LOG_LINES=$(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)
  MANIFEST_LINES=$(wc -l < "$MANIFEST" 2>/dev/null || echo 0)
  SHA=$(tail -100 "$LOGS/constellation25.log" 2>/dev/null | sha256sum | cut -d' ' -f1)
  echo "[$TS] [$NAME] FORENSIC_SNAPSHOT log_bytes:$LOG_SIZE log_lines:$LOG_LINES manifest_entries:$MANIFEST_LINES sha256:$SHA" >> "$LOGS/constellation25.log"
  echo "[$TS] [SATURN] [SNAPSHOT] SHA256:$SHA lines:$LOG_LINES" >> "$MANIFEST"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/saturn.log"
  sleep 300
done
