#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME"
STACK_DIR="$ROOT/STACK/source"
LOG_DIR="$ROOT/STACK/logs"
mkdir -p "$LOG_DIR"

echo "🚀 STACK BOOT — $(date)"
echo "📂 Stack source: $STACK_DIR"

declare -A STACK_ENTRYPOINTS
declare -a STACK_ORDER

# -------------------------------
# 1. DISCOVER + VALIDATE STACKS
# -------------------------------
for f in "$STACK_DIR"/*.json; do
  echo "→ Inspecting $(basename "$f")"

  jq -e '
    .stack
    and .type
    and .entrypoint
    and (.responsibility | type == "array")
  ' "$f" >/dev/null || {
    echo "❌ Invalid stack file: $f"
    exit 1
  }

  STACK=$(jq -r '.stack' "$f")
  ENTRY=$(jq -r '.entrypoint' "$f")

  STACK_ENTRYPOINTS["$STACK"]="$ENTRY"
  STACK_ORDER+=("$STACK")

  echo "✔ Registered stack: $STACK"
done

# -------------------------------
# 2. EXECUTION (ORCHESTRATOR FIRST)
# -------------------------------
run_stack () {
  local name="$1"
  local entry="$ROOT/${STACK_ENTRYPOINTS[$name]}"

  echo "⚙️  Booting $name → $entry"

  if [[ ! -x "$entry" ]]; then
    echo "❌ Entrypoint not executable: $entry"
    exit 1
  fi

  "$entry" >>"$LOG_DIR/$name.log" 2>&1 &
  echo "✅ $name started (PID $!)"
}

# Sovereign system always first
run_stack "SOVEREIGN_SYSTEM"

# Small delay so it claims control
sleep 1

# Everything else
for s in "${STACK_ORDER[@]}"; do
  [[ "$s" == "SOVEREIGN_SYSTEM" ]] && continue
  run_stack "$s"
done

echo "🧠 ALL STACKS ONLINE"
echo "📜 Logs in $LOG_DIR"
