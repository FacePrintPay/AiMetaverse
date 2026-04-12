#!/bin/bash
echo "📦 Grabbing repositories..."
cd "$HOME/constellation25_workspace" || exit
if [ -f "constellation_consolidator.sh" ]; then
    ./constellation_consolidator.sh
else
    echo "⚠️  constellation_consolidator.sh not found"
    echo "Run the master setup first."
fi
