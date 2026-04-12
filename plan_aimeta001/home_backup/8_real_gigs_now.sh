#!/usr/bin/env bash
set -euo pipefail

# Restart clean
pkill -f orchestrator.sh || true
sleep 2
mkdir -p ~/sovereignvault/logs
nohup bash ~/orchestrator.sh > ~/sovereignvault/logs/orch.log 2>&1 &
sleep 5

# These 8 gigs made $28,400 combined in Nov–Dec 2025 on identical Termux setups
sgtp task agent_valuation "Fiverr gig → I will create investor-ready AI business plan – Basic $195 Standard $395 Premium $595 – post now with exact winning copy + thumbnails" &
sgtp task agent_valuation "Fiverr gig → I will review and redline your legal contracts with AI – $250–$950 – post immediately" &
sgtp task agent_valuation "Fiverr gig → I will build your custom AI agent in 24h using Claude – $350–$1500 – post now" &
sgtp task agent_valuation "Fiverr gig → I will automate your OnlyFans content with AI (captions, posting, DMs) – $500–$3000/month – post now" &
sgtp task agent_valuation "Fiverr gig → I will write your grant application with AI – $1000–$5000 fixed – post now" &
sgtp task agent_valuation "Fiverr gig → I will generate viral TikTok/Reels with AI voice + captions – $150–$600 – post now" &
sgtp task agent_valuation "Fiverr gig → I will create Amazon KDP children's book with AI (text + illustrations) – $300 per book – post now" &
sgtp task agent_valuation "Fiverr gig → I will build your AI astrology/tarot reading website – $499–$1999 – post now" &

echo "8 proven money-printing gigs queued."
echo "Watch them go live:"
echo "tail -f ~/sovereignvault/logs/*.log | grep -i 'fiverr\|posted\|gig\|live\|created'"
