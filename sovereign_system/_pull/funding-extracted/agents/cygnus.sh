#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="cygnus"
EVIDENCE="$C25/evidence"
mkdir -p "$EVIDENCE"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  SHA=$(cat "$LOGS/totalrecall_manifest.log" 2>/dev/null | sha256sum | cut -d' ' -f1)
  ENTRIES=$(wc -l < "$LOGS/totalrecall_manifest.log" 2>/dev/null || echo 0)
  echo "[$TS] [$NAME] EVIDENCE_INTEGRITY manifest_entries:$ENTRIES sha256:$SHA" >> "$LOGS/constellation25.log"
  # Create timestamped evidence snapshot
  cp "$LOGS/totalrecall_manifest.log" "$EVIDENCE/manifest_snapshot_$(date +%Y%m%d).log" 2>/dev/null
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/cygnus.log"
  sleep 3600
done
