#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export PATH="$PATH:$HOME/YesQuid"

echo "🌱 [REVENUE] Refreshing SOVEREIGN_MASTER index..."
if [[ -f "$HOME/yesquid_master_index.sh" ]]; then
  bash "$HOME/yesquid_master_index.sh"
fi

if [[ -f "$HOME/yesquid_master_materialize.sh" ]]; then
  bash "$HOME/yesquid_master_materialize.sh"
fi

echo "🌱 [REVENUE] Seeding 1000-task Supervity backlog..."
if [[ -f "$HOME/YesQuid/supervity_seed_1000.sh" ]]; then
  bash "$HOME/YesQuid/supervity_seed_1000.sh"
else
  echo "[WARN] supervity_seed_1000.sh not found at $HOME/YesQuid/"
fi

echo "🚀 [REVENUE] Ensuring orchestrator is running..."
sgtp start || true

echo "💸 [REVENUE] Sending monetization task to Mercury..."
sgtp task mercury_nlp_analysis "Monetize all existing offers via swarm"

echo "✅ [REVENUE] Monetization pipeline triggered. Check your logs for results."
