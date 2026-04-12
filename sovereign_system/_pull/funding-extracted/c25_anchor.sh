#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"
LOGS="$C25/logs"
MANIFEST="$LOGS/totalrecall_manifest.log"
TS=$(date "+%Y-%m-%d %H:%M:%S %Z")
SHA=$(echo "c25-anchor-$TS-$$" | sha256sum | cut -d' ' -f1)

mkdir -p "$LOGS"

echo "╔══════════════════════════════════════════════╗"
echo "║   CONSTELLATION25 — ANCHOR HEARTBEAT        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Time  : $TS"
echo "  SHA256: $SHA"
echo ""

# Count running agents
RUNNING=0
for PID_FILE in "$C25/agents/"*.pid 2>/dev/null; do
  [ -f "$PID_FILE" ] || continue
  PID=$(cat "$PID_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    RUNNING=$((RUNNING+1))
  fi
done

# Count pending tasks
PENDING=$(find "$C25/tasks" -name "*.json" 2>/dev/null | wc -l)

# Count log lines
LOG_LINES=$(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)

echo "  Agents running : $RUNNING"
echo "  Tasks pending  : $PENDING"
echo "  Log entries    : $LOG_LINES"
echo "  MCP server     : $(pgrep -f mcp-stdlib.py > /dev/null && echo RUNNING || echo STOPPED)"
echo "  Port 3000      : $(curl -s --max-time 1 http://localhost:3000/status 2>/dev/null && echo OK || echo STOPPED)"
echo ""

# Write anchor to TotalRecall manifest
echo "[$TS] [ANCHOR] [HEARTBEAT] SHA256:$SHA agents:$RUNNING tasks:$PENDING log_lines:$LOG_LINES" >> "$MANIFEST"

echo "  ✅ Anchor written to TotalRecall manifest"
echo "  📜 $MANIFEST"
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   CONSTELLATION25 ANCHOR COMPLETE           ║"
echo "╚══════════════════════════════════════════════╝"
