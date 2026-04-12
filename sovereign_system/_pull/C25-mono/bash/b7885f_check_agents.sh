#!/data/data/com.termux/files/usr/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   PaTHos Agent System Status${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check running processes
echo -e "${GREEN}Running Agents:${NC}"
ps aux | grep "_agent.py" | grep -v grep || echo "  No agents running"
echo ""

# Check bus
if [ -f ~/agents_bus.json ]; then
  echo -e "${GREEN}Agent Bus:${NC}"
  python3 -c "
import json
with open('$HOME/agents_bus.json', 'r') as f:
    bus = json.load(f)
    print(f\"  Registered agents: {len(bus.get('agents', {}))}\"  )
    print(f\"  Total messages: {len(bus.get('messages', []))}\")
    print(f\"  Unprocessed: {sum(1 for m in bus.get('messages', []) if not m.get('processed'))}\")
"
  echo ""
fi

# Recent logs
echo -e "${GREEN}Recent Activity:${NC}"
for log in ~/logs/agents/*.log; do
  if [ -f "$log" ]; then
    name=$(basename "$log" .log)
    count=$(wc -l < "$log")
    last=$(tail -n 1 "$log" 2>/dev/null || echo "No entries")
    echo -e "  ${YELLOW}$name${NC}: $count lines"
    echo "    Latest: $last"
  fi
done
