#!/bin/bash
echo "🌌 CONSTELLATION-25 • STARTING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check Ollama
if ! pgrep -x "ollama" > /dev/null; then
  echo "🤖 Starting Ollama..."
  ollama serve > /dev/null 2>&1 &
  sleep 3
fi

# Check model
if ! ollama list 2>/dev/null | grep -q "qwen2.5"; then
  echo "⚠️  Pulling Qwen model..."
  ollama pull qwen2.5:7b
fi

echo "⚛️  Launching UI..."
echo "👉 http://localhost:3000"
npm run dev
