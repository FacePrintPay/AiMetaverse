#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="vega"
DATA="$C25/data"
mkdir -p "$DATA"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for CSV in "$C25/tasks"/*.csv; do
    [ -f "$CSV" ] || continue
    ROWS=$(wc -l < "$CSV")
    echo "[$TS] [$NAME] CSV_PROCESS file:$CSV rows:$ROWS" >> "$LOGS/constellation25.log"
    mv "$CSV" "$DATA/processed_$(basename $CSV)"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/vega.log"
  sleep 60
done
