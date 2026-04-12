#!/bin/bash
set -euo pipefail
# REPO: AiKre8tive-Stargate | FILE: whisper_auto_loop.sh | CONSTELLATION25

#!/bin/bash

echo "🔁 Running WhisperSync Auto-Loop..."

# Define timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check for voice input file (e.g., via speech-to-text system)
voice_input="text.txt"

# Check if text.txt exists
if [ -f "$voice_input" ]; then
    input_content=$(cat "$voice_input")
    echo "$timestamp - [Voice/Text] $input_content" >> ./logs/whispersync.log
    echo "🧠 Entry added from $voice_input"
else
    echo "$timestamp - [System] No voice or text input detected." >> ./logs/whispersync.log
    echo "⚠️ No input file found. Logged default system note."
fi

# Optional: Auto-commit to Git if network available
if ping -q -c 1 -W 1 github.com > /dev/null; then
    bash ./git_autocommit.sh
else
    echo "🌐 Git not pushed — no internet detected."
fi

echo "✅ WhisperSync cycle complete."
