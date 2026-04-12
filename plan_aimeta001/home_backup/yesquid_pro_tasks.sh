#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Load guard
if [[ -f "$HOME/yesquid_guard.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/yesquid_guard.sh"
  yesquid_core_check
else
  echo "[WARN] yesquid_guard.sh missing – no safety checks."
fi

TASKS_FILE="${TASKS_FILE:-$HOME/yesquid_tasks.txt}"

if [[ -f "$HOME/yesquid_guard.sh" ]]; then
  require_file "$TASKS_FILE"
fi

while IFS='|' read -r id tags title; do
  [[ -z "$id" ]] && continue
  [[ "$id" =~ ^# ]] && continue

  echo "Task $id | $tags | $title"

  case "$id" in
    T001)
      echo "Launching FULL REVENUE SWARM (Fiverr + Upwork + Gumroad)"
      require_cmd sgtp
      sgtp task agent_valuation \
        "Launch full revenue swarm: Fiverr gigs, Upwork profile, Gumroad Sovereign Pack" &
      ;;
    T002)
      echo "Refreshing All-in-One YesQuid pipeline (seed 1000-task backlog)"
      require_file "$HOME/YesQuid/supervity_seed_1000.sh"
      bash "$HOME/YesQuid/supervity_seed_1000.sh"
      ;;
    T003)
      echo "Launching SovereignGTP swarm + monetization from Mercury"
      require_cmd sgtp
      sgtp start
      sgtp task mercury_nlp_analysis \
        "Monetize all existing offers via swarm"
      ;;
    T900)
      echo "Refreshing SOVEREIGN MASTER index + symlink tree"
      require_file "$HOME/yesquid_master_index.sh"
      require_file "$HOME/yesquid_master_materialize.sh"
      bash "$HOME/yesquid_master_index.sh"
      bash "$HOME/yesquid_master_materialize.sh"
      ;;
    *)
      echo "No auto-action for $id yet"
      ;;
  esac
done < "$TASKS_FILE"

echo "All tasks queued."
