#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"
LOGS="$C25/logs"
TS=$(date "+%Y-%m-%d %H:%M:%S %Z")
SHA=$(echo "constellation25-liftoff-$TS-$$" | sha256sum | cut -d' ' -f1)

mkdir -p "$LOGS" "$C25/tasks" "$C25/agents"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║          🌌  C O N S T E L L A T I O N  2 5  🌌            ║"
echo "║                    L I F T O F F                            ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Version   : 25.0.0"
echo "  Timestamp : $TS"
echo "  SHA256    : $SHA"
echo "  Operator  : u0_a510"
echo ""
echo "  [1/5] Verifying system..."
bash "$C25/verify.sh" 2>/dev/null | grep -E "✅|❌|Python|Bash"
echo ""

echo "  [2/5] Starting MCP server..."
if pgrep -f mcp-stdlib.py > /dev/null; then
  echo "  ✅ MCP server already running"
else
  python3 "$C25/mcp-stdlib.py" &
  MCP_PID=$!
  sleep 1
  if kill -0 "$MCP_PID" 2>/dev/null; then
    echo "  ✅ MCP server started (PID $MCP_PID)"
    echo "$MCP_PID" > "$C25/mcp.pid"
  else
    echo "  ⚠️  MCP server failed to start — check mcp-stdlib.py"
  fi
fi
echo ""

echo "  [3/5] Starting all 25 agents..."
bash "$C25/run_agent.sh" all
echo ""

echo "  [4/5] Writing liftoff anchor to TotalRecall..."
echo "[$TS] [LIFTOFF] [v25.0.0] SHA256:$SHA — Constellation25 liftoff complete" >> "$LOGS/totalrecall_manifest.log"
echo "[$TS] [LIFTOFF] [OPERATOR] u0_a510" >> "$LOGS/totalrecall_manifest.log"
echo "  ✅ Anchor written"
echo ""

echo "  [5/5] Anchor heartbeat..."
bash "$C25/c25_anchor.sh"
echo ""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   🌌 CONSTELLATION25 LIFTOFF COMPLETE — ALL SYSTEMS GO  🌌  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Monitor : tail -f $LOGS/constellation25.log"
echo "  Status  : bash $C25/c25_anchor.sh"
echo "  Tasks   : bash $C25/queue_task.sh [agent] [action] [target]"
echo ""
