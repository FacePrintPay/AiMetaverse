#!/data/data/com.termux/files/usr/bin/bash
echo "🌐 Linking Planetary Agent Nodes..."
for agent in ~/AiKre8tiveGenesis/platform/backend/agents/*.py; do
  name=$(basename "$agent" .py)
  nohup python "$agent" > ~/AiKre8tiveGenesis/platform/logs/${name}.log 2>&1 &
  echo "✅ Launched $name agent"
done
