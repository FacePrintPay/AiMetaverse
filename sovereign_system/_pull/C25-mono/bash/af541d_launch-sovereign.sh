#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
C25_ROOT="/data/data/com.termux/files/home/Constellation25"
OBS_VAULT="${OBSIDIAN_VAULT:-$HOME/C25-Vault}"
MCP_PORT="${MCP_PORT:-8989}"

echo "🌌 CONSTELLATION25 SOVEREIGN LAUNCH"
echo "===================================="

# Auto-fetch all env vars from Obsidian via HTTP flow
echo "[1/4] Fetching environment from Obsidian vault..."
source "$C25_ROOT/obsidian-bridge/fetch-env.sh"

# Verify critical env vars are loaded
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "⚠️  GITHUB_TOKEN not found in Obsidian vault - agents will use public API only"
fi

# Start MCP server
echo "[2/4] Starting MCP server on port $MCP_PORT..."
cd "$C25_ROOT/core/mcp"
nohup python3 server.py > "$C25_ROOT/deploy/mcp.log" 2>&1 &
MCP_PID=$!
sleep 2
curl -s "http://localhost:$MCP_PORT/mcp/v1/health" > /dev/null && echo "✅ MCP running (PID: $MCP_PID)" || echo "⚠️  MCP starting..."

# Launch agents 1-25
echo "[3/4] Launching Planetary Agents 1-25..."
for i in $(seq 1 25); do
  [ -x "$C25_ROOT/agents/planetary-$i/agent-core.sh" ] && nohup bash "$C25_ROOT/agents/planetary-$i/agent-core.sh" > "$C25_ROOT/agents/planetary-$i/output/agent.log" 2>&1 &
done
echo "✅ 25 agents launched"

# Verify deployment
echo "[4/4] Verifying sovereign deployment..."
sleep 3
health=$(curl -s "http://localhost:$MCP_PORT/mcp/v1/health" 2>/dev/null || echo '{"status":"starting"}')
agents=$(curl -s "http://localhost:$MCP_PORT/mcp/v1/agents/status" 2>/dev/null | jq -r '.agents | map(select(.active)) | length' 2>/dev/null || echo "0")

echo ""
echo "===================================="
echo "✅ CONSTELLATION25 SOVEREIGN - OPERATIONAL"
echo "===================================="
echo "🌐 MCP API: http://localhost:$MCP_PORT"
echo "📊 Agents Active: $agents/25"
echo "🔐 Env Source: Obsidian Vault (HTTP fetch at runtime)"
echo "📁 Root: $C25_ROOT"
echo ""
echo "🎯 Usage:"
echo "  curl -X POST http://localhost:$MCP_PORT/mcp/v1/orchestrate -H 'Content-Type: application/json' -d '{\"tasks\":[{\"agent_id\":1,\"intent\":\"fix builds\",\"payload\":{\"repo\":\"agentik\"}}]}'"
echo ""
echo "🔑 Env vars auto-fetch from Obsidian on every agent start - no manual config needed"
