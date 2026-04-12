# REPO: c25-deploy-sovereign | FILE: deploy_sovereign.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
# Sovereign deployment script
set -euo pipefail
echo "🚀 Initiating Sovereign Planetary Agent deployment..."
# Install dependencies
echo "📦 Installing dependencies..."
pkg install -y nodejs python git curl
# Set up NPM global directory
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
# Install Express for server
npm install -g express cors body-parser
# Launch orchestrator server in background
echo "🌌 Starting sovereign orchestrator..."
nohup node "$HOME/sovereign/core/orchestrator_server.js" > "$HOME/sovereign/server.log" 2>&1 &
SERVER_PID=$!
echo "⏱️  Waiting for server to initialize..."
sleep 3
# Launch ngrok tunnel
echo "🚇 Establishing sovereign tunnel..."
"$HOME/sovereign/launch_tunnel.sh"
echo ""
echo "✅ SOVEREIGN DEPLOYMENT COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 Public Endpoint: $(jq -r '.public_url' "$HOME/sovereign/config.json")"
echo "🔑 API Key: $(jq -r '.api_key' "$HOME/sovereign/config.json")"
echo "⚡ Server PID: $SERVER_PID"
echo "📁 Log Files:"
echo "   - Server: $HOME/sovereign/server.log"
echo "   - Orchestration: $HOME/sovereign/orchestration.log"
echo "   - Failures: $HOME/sovereign/failures.log"
echo ""
echo "🛡️  Your Planetary Agents are now active:"
echo "   - Mercury: Research & analysis"
echo "   - [Add more agents as you implement them]"
echo ""
echo "To test your sovereign system:"
echo "curl -X POST $(jq -r '.public_url' "$HOME/sovereign/config.json")/api/execute \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Sovereign-User: cygel.co@gmail.com\" \\"
echo "  -d '{\"agent\": \"mercury-agent\", \"type\": \"research\", \"payload\": {\"query\": \"sovereign AI architecture\"}}'"
echo ""
echo "To stop services: pkill -f orchestrator_server.js && pkill ngrok"
