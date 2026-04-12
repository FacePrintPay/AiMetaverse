#!/bin/bash
echo "🤖 Auto-committing changes to GitHub..."
cd "$HOME/constellation25_workspace" || exit
git add .
git commit -m "🤖 WhisperSync auto-commit $(date '+%Y-%m-%d %H:%M')"
git pull --rebase origin main 2>/dev/null || true
git push origin main
echo "✅ Changes pushed successfully."
