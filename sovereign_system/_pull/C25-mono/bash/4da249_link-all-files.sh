#!/bin/bash
echo "🔗 Linking all files..."
cd "$HOME/constellation25_workspace" || exit
find . -type f -name "*.sh" -exec chmod +x {} \;
echo "All scripts made executable."
