#!/usr/bin/env bash
set -euo pipefail

pkill -f orchestrator.sh || true
sleep 2
nohup bash ~/orchestrator.sh > ~/sovereignvault/logs/orch.log 2>&1 &
sleep 5

sgtp task agent_valuation "FIVERR GIG NOW: I will create investor-ready AI business plan – $195 basic / $395 standard / $595 premium – post immediately with proven copy + thumbnails" &
sgtp task agent_valuation "FIVERR GIG NOW: I will review and redline your legal contracts with AI – $250–$950 – post now" &
sgtp task agent_valuation "GUMROAD NOW: Sovereign Agent Pack 2026 – $99 – use all existing code + winning sales page – launch immediately" &

echo "3 real money tasks queued. Nothing else matters."
echo "Watch: tail -f ~/sovereignvault/logs/*.log"
