#!/data/data/com.termux/files/usr/bin/bash
# Monetization Pulse - Fixed Version

set -e
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "💰 [MONETIZE PULSE] Starting at $TIMESTAMP"
echo ""

# Run planetary agents
echo "🤖 Running planetary agents..."
if [ -f ~/AGENTS/main.py ]; then
    python3 ~/AGENTS/main.py --mode automated
else
    echo "  ⚠ AGENTS not found, skipping"
fi
echo ""

# Generate PaTHos bundle
echo "📦 Generating PaTHos bundle..."
if [ -f ~/PaTHos/scripts/generate_bundle.py ]; then
    python3 ~/PaTHos/scripts/generate_bundle.py --type weekly
else
    echo "  ⚠ PaTHos not found, skipping"
fi
echo ""

# Publish AIRecords
echo "🎵 Publishing AIRecords drop..."
if [ -f ~/AIRecords/scripts/publish_drop.js ]; then
    node ~/AIRecords/scripts/publish_drop.js
else
    echo "  ⚠ AIRecords scripts not found, skipping"
fi
echo ""

# Run marketing
echo "📢 Running marketing automation..."
if [ -f ~/SOVEREIGN_GTP/agents/run_marketing.sh ]; then
    bash ~/SOVEREIGN_GTP/agents/run_marketing.sh
else
    echo "  ⚠ Marketing scripts not found, skipping"
fi
echo ""

echo "✅ [COMPLETE] Monetization pulse completed at $(date +"%Y-%m-%d %H:%M:%S")"
