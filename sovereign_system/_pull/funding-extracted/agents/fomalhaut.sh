#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="fomalhaut"
REVENUE="$C25/revenue"
mkdir -p "$REVENUE"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  # Track revenue events
  for EVENT in "$C25/tasks"/revenue_*.json; do
    [ -f "$EVENT" ] || continue
    AMOUNT=$(python3 -c "import json; d=json.load(open('$EVENT')); print(d.get('amount',0))" 2>/dev/null)
    SOURCE=$(python3 -c "import json; d=json.load(open('$EVENT')); print(d.get('source','unknown'))" 2>/dev/null)
    SHA=$(echo "$AMOUNT-$SOURCE-$TS" | sha256sum | cut -d' ' -f1)
    echo "[$TS] [$NAME] REVENUE amount:$AMOUNT source:$SOURCE sha256:$SHA" >> "$LOGS/constellation25.log"
    echo "[$TS] [FOMALHAUT] [REVENUE] SHA256:$SHA amount:$AMOUNT source:$SOURCE" >> "$LOGS/totalrecall_manifest.log"
    echo "{\"timestamp\":\"$TS\",\"amount\":\"$AMOUNT\",\"source\":\"$SOURCE\",\"sha256\":\"$SHA\"}" >> "$REVENUE/ledger.json"
    mv "$EVENT" "$EVENT.done"
  done
  TOTAL=$(grep "REVENUE amount:" "$LOGS/constellation25.log" 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] STATUS:OK revenue_events:$TOTAL" >> "$LOGS/fomalhaut.log"
  sleep 60
done
