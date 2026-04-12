#!/bin/bash
set -euo pipefail
# REPO: AiKre8tive-Stargate | FILE: buzzblast.sh | CONSTELLATION25

#!/bin/bash
echo "📢 Launching BuzzBlast press + publication payload..."
if [ -d "./presskit" ]; then
    echo "📰 Packaging press release..."
    zip -r presskit.zip presskit/
    echo "🚀 Sending to media distribution channel (placeholder)..."
    # curl -F "file=@presskit.zip" https://media.kre8tive.space/upload
    echo "✅ BuzzBlast complete."
else
    echo "⚠️ presskit directory not found. BuzzBlast aborted."
fi
