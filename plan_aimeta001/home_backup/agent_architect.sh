#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARCHITECT_ID="sovereign_architect"
PROFILE_FILE="$HOME/profiles/sovereign_architect_profile.json"
PLANS_DIR="$HOME/plans"
TASKS_DIR="$HOME/tasks/incoming"

mkdir -p "$PLANS_DIR" "$TASKS_DIR"

if [[ $# -lt 1 ]]; then
  echo "Usage: agent_architect.sh \"High-level goal...\""
  exit 1
fi

GOAL="$1"
PLAN_ID="plan_$(date +%s%N)"
PLAN_FILE="$PLANS_DIR/${PLAN_ID}.json"

echo "🧠 Architect planning for goal:"
echo "   \"$GOAL\""
echo "   → $PLAN_FILE"

python "$HOME/agents/architect_planner.py" \
  --profile "$PROFILE_FILE" \
  --goal "$GOAL" \
  --out "$PLAN_FILE"

if [[ ! -s "$PLAN_FILE" ]]; then
  echo "❌ Planner failed to create plan file."
  exit 1
fi

echo "📋 Plan created: $PLAN_FILE"
echo "🔁 Enqueuing steps as tasks..."

python "$HOME/agents/architect_enqueue.py" \
  --plan "$PLAN_FILE" \
  --tasks-dir "$TASKS_DIR"

echo "🚀 Pipeline queued. Orchestrator will pick up tasks as normal."
