#!/usr/bin/env bash
set -euo pipefail

echo "🌌 Patching Constellation 25 into cleanbuildfresh.vercel.app..."

cd ~/github-repos/cleanbuildfresh

# Create public directory for static dashboard
mkdir -p public/constellation

# Copy your dashboard
cp ~/github-repos/constellation25/aimetaverse-dashboard.html public/constellation/dashboard.html

# Create index redirect
cat > public/constellation/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="refresh" content="0; url=dashboard.html">
  <title>🌌 Constellation 25 → Pathos-Sovereign-1</title>
</head>
<body style="background:#0a0e27;color:#00ff88;text-align:center;padding:50px;font-family:monospace">
  <h1>🌌 Constellation 25</h1>
  <p>Redirecting to sovereign command center...</p>
  <p><a href="dashboard.html" style="color:#00ddff">Click here if not redirected</a></p>
</body>
</html>
EOF

# Add to git
git add public/constellation/
git commit -m "🌌 Add Constellation 25 Dashboard @ /constellation

- 27-agent planetary swarm
- Qwen NLP router + Ollama offline fallback
- Termux-native execution
- Architect: Cygel White" || echo "No changes to commit"

# Push
git push origin main

echo ""
echo "✅ PATCHED! Your dashboard is deploying to:"
echo "   → https://cleanbuildfresh.vercel.app/constellation"
echo ""
echo "📱 Mobile: https://cleanbuildfresh.vercel.app/constellation/dashboard.html"
echo "🔐 Architect attribution preserved"
