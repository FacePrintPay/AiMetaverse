#!/data/data/com.termux/files/usr/bin/bash
# Run a plan end-to-end with REAL filesystem invariants
set -euo pipefail

PLAN_ID="${1:-52f7b763}"

ROOT="$HOME/sovereign-architect"
PLANS="$HOME/plans"
TASKS="$HOME/tasks"
BUNDLE="$TASKS/incoming/plan_${PLAN_ID}_tasks_1000.json"
ACTIVE_DIR="$TASKS/active/plan_${PLAN_ID}"
DONE_DIR="$TASKS/done/plan_${PLAN_ID}"
ART_ROOT="$ROOT/storage/artifacts/plan_${PLAN_ID}"
LOGS="$HOME/TotalRecall/run_logs"
WORKER="$ROOT/agents/yesquid_task_worker.sh"

mkdir -p "$TASKS/incoming" "$ACTIVE_DIR" "$DONE_DIR" "$ART_ROOT" "$LOGS"

echo "=== SOVEREIGN ARCHITECT STRICT RUN ==="
echo "PLAN_ID = $PLAN_ID"

# ---- 0. Validate worker exists ----
if [[ ! -x "$WORKER" ]]; then
  echo "[FATAL] Worker missing or not executable: $WORKER"
  exit 1
fi

# ---- 1. Validate plan file ----
PLAN_FILE=$(ls "$PLANS"/plan_${PLAN_ID}_*.json 2>/dev/null | head -n 1 || true)
if [[ -z "$PLAN_FILE" ]]; then
  echo "[FATAL] Plan file not found for ID: $PLAN_ID under $PLANS"
  exit 1
fi
echo "[OK] Using plan: $PLAN_FILE"

# ---- 2. Generate bundle (or validate existing) ----
if [[ -f "$BUNDLE" ]]; then
  echo "[*] Existing bundle found: $BUNDLE"
else
  echo "[*] Generating fresh 1000-task bundle..."
  python3 "$ROOT/agents/generate_1000_tasks.py" "$PLAN_FILE"
fi

if [[ ! -f "$BUNDLE" ]]; then
  echo "[FATAL] Bundle not present after generation: $BUNDLE"
  exit 1
fi

# Sanity check bundle
TOTAL_IN_BUNDLE=$(jq '.total_tasks' "$BUNDLE" 2>/dev/null || echo 0)
if [[ "$TOTAL_IN_BUNDLE" -ne 1000 ]]; then
  echo "[FATAL] Bundle total_tasks != 1000 (got $TOTAL_IN_BUNDLE)"
  exit 1
fi
echo "[OK] Bundle total_tasks = $TOTAL_IN_BUNDLE"

# ---- 3. Fanout to individual task files ----
echo "[*] Fanning out tasks into: $ACTIVE_DIR"
python3 "$ROOT/agents/fanout_tasks_to_files.py" "$BUNDLE"

ACTIVE_COUNT=$(ls "$ACTIVE_DIR"/*.json 2>/dev/null | wc -l || echo 0)
if [[ "$ACTIVE_COUNT" -eq 0 ]]; then
  echo "[FATAL] Fanout produced 0 active task files in $ACTIVE_DIR"
  exit 1
fi
echo "[OK] Active task count after fanout: $ACTIVE_COUNT"

# ---- 4. STRICT worker loop ----
echo "[*] Running strict worker on all tasks..."
LOOP_ITER=0
while :; do
  LOOP_ITER=$((LOOP_ITER+1))
  NEXT_TASK=$(ls "$ACTIVE_DIR"/*.json 2>/dev/null | head -n 1 || true)

  if [[ -z "$NEXT_TASK" ]]; then
    echo "[OK] No tasks left in $ACTIVE_DIR"
    break
  fi

  echo "[*] Iteration $LOOP_ITER – processing $(basename "$NEXT_TASK")"
  # If worker fails, bail hard
  if ! "$WORKER" "$PLAN_ID"; then
    echo "[FATAL] Worker failed on iteration $LOOP_ITER."
    echo "        Last task: $NEXT_TASK"
    exit 1
  fi
done

# ---- 5. Compute ground-truth from filesystem ----
ACTIVE_COUNT=$(ls "$ACTIVE_DIR"/*.json 2>/dev/null | wc -l || echo 0)
DONE_COUNT=$(ls "$DONE_DIR"/*.json 2>/dev/null | wc -l || echo 0)
ART_COUNT=$(find "$ART_ROOT" -type f 2>/dev/null | wc -l || echo 0)

echo ""
echo "============================"
echo "  TOTAL RECALL SUMMARY"
echo "============================"
echo "Plan ID:        $PLAN_ID"
echo "Tasks ACTIVE:   $ACTIVE_COUNT"
echo "Tasks DONE:     $DONE_COUNT"
echo "Artifacts MADE: $ART_COUNT"
echo "Artifact path:  $ART_ROOT"
echo "============================"

# Invariant checks
if [[ "$ACTIVE_COUNT" -ne 0 ]]; then
  echo "[WARN] There are still $ACTIVE_COUNT active tasks. Not all work was consumed."
fi

if [[ "$DONE_COUNT" -eq 0 ]]; then
  echo "[WARN] No done tasks. Worker may not have performed any work."
fi

TS=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOGS/recap_${PLAN_ID}_${TS}.txt"

{
  echo "Plan: $PLAN_ID"
  echo "Plan file: $PLAN_FILE"
  echo "Bundle: $BUNDLE"
  echo "Active dir: $ACTIVE_DIR"
  echo "Done dir: $DONE_DIR"
  echo "Artifacts root: $ART_ROOT"
  echo "Active tasks: $ACTIVE_COUNT"
  echo "Done tasks: $DONE_COUNT"
  echo "Artifacts: $ART_COUNT"
  echo "Timestamp: $(date -Iseconds)"
} > "$LOG_FILE"

echo "[LOG SAVED] $LOG_FILE"
