#!/bin/bash
set -euo pipefail
# REPO: AiKre8tive-Stargate | FILE: git_autocommit.sh | CONSTELLATION25

#!/bin/bash
echo "📥 Auto-committing changes to GitHub..."
git add .
git commit -m "🤖 WhisperSync auto-commit"
git pull --rebase origin main
git push origin main
echo "✅ Changes pushed successfully."
