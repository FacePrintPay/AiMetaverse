#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 WhisperSync Activated..."
nohup bash ~/AiKre8tiveGenesis/platform/run_whispersync_agent.sh > ~/AiKre8tiveGenesis/platform/logs/whispersync.log 2>&1 &
echo "📡 WhisperSync Running in Background"
