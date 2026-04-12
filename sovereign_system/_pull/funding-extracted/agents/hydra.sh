#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="hydra"
PIPELINE="$C25/pipeline"
mkdir -p "$PIPELINE"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for JOB in "$C25/tasks"/cicd_*.json; do
    [ -f "$JOB" ] || continue
    STAGE=$(python3 -c "import json; d=json.load(open('$JOB')); print(d.get('stage','build'))" 2>/dev/null)
    echo "[$TS] [$NAME] PIPELINE stage:$STAGE" >> "$LOGS/constellation25.log"
    mv "$JOB" "$JOB.done"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/hydra.log"
  sleep 60
done
