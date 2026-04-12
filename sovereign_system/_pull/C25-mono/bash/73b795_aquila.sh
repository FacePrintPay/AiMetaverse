#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="aquila"
INDEX="$C25/search_index"
mkdir -p "$INDEX"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  for QUERY in "$C25/tasks"/search_*.json; do
    [ -f "$QUERY" ] || continue
    TERM=$(python3 -c "import json; d=json.load(open('$QUERY')); print(d.get('query',''))" 2>/dev/null)
    RESULTS=$(grep -rl "$TERM" "$C25" 2>/dev/null | head -10)
    echo "[$TS] [$NAME] SEARCH query:$TERM results:$(echo "$RESULTS" | wc -l)" >> "$LOGS/constellation25.log"
    echo "$RESULTS" > "$INDEX/results_$(date +%s).txt"
    mv "$QUERY" "$QUERY.done"
  done
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/aquila.log"
  sleep 60
done
