#!/data/data/com.termux/files/usr/bin/bash
# Sovereign tunnel launcher
export PATH="$HOME/.npm-global/bin:$PATH"
echo "🚇 Launching sovereign ngrok tunnel..."
if ! command -v ngrok &> /dev/null; then
  echo "📦 Installing ngrok..."
  npm install -g ngrok
fi
# Start tunnel in background
ngrok http 8080 --region us --log=stdout > /dev/null 2>&1 &
TUNNEL_PID=$!
echo "⏱️  Waiting for tunnel to initialize..."
sleep 5
# Get public URL
PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-z0-9\-]*\.ngrok\.io' | head -1)
if [ -z "$PUBLIC_URL" ]; then
  echo "❌ Failed to get ngrok URL"
  kill $TUNNEL_PID
  exit 1
fi
echo "🌐 Sovereign endpoint exposed at: $PUBLIC_URL"
echo "KEY Sovereign API Key: $(openssl rand -hex 16)"
# Save to sovereign config
cat > "$HOME/sovereign/config.json" << EOL
{
  "public_url": "$PUBLIC_URL",
  "api_key": "$(openssl rand -hex 16)",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOL
echo "✅ Sovereign tunnel established - agents ready for orchestration"
