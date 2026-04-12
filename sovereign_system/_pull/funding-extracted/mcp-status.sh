#!/data/data/com.termux/files/usr/bin/bash

echo "=== Constellation25 MCP Server Status ==="
echo ""

# Check if MCP library is installed
if python3 -c "import mcp" 2>/dev/null; then
    echo "✅ MCP library: Installed"
else
    echo "❌ MCP library: Not installed"
    echo "   Run: pip install mcp"
fi

# Check if server script exists
if [ -f ~/constellation25/mcp-server.py ]; then
    echo "✅ MCP server script: Exists"
else
    echo "❌ MCP server script: Not found"
fi

# Check if config exists
if [ -f ~/.config/Claude/claude_desktop_config.json ]; then
    echo "✅ Claude Desktop config: Exists"
    echo "   Config location: ~/.config/Claude/claude_desktop_config.json"
else
    echo "❌ Claude Desktop config: Not found"
fi

# Check if agents are running
agent_count=$(ps aux | grep agent.sh | grep -v grep | wc -l)
echo "✅ Running agents: $agent_count/25"

echo ""
echo "To start MCP server:"
echo "  python3 ~/constellation25/mcp-server.py"
echo ""
echo "To use with Claude Desktop:"
echo "  1. Install Claude Desktop"
echo "  2. Config is already at ~/.config/Claude/claude_desktop_config.json"
echo "  3. Restart Claude Desktop"
