#!/bin/bash
echo "🛰️ Deploying Planetary AI Agents from ArcBase..."

AGENTS_DIR="./agents"
for agent in "$AGENTS_DIR"/*.sh; do
  echo "🔁 Launching $(basename "$agent")"
  bash "$agent"
done

echo "✅ All agents deployed."
