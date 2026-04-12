#!/data/data/com.termux/files/usr/bin/bash
# YESQUIDPRO COMPLIANT EXECUTION – LEGYC PRIORITY RUNNER v1.3
# Runs preservation + damages tasks with absolute-path logic

set -euo pipefail
BASE="/data/data/com.termux/files/home/TotalRecall/complaint_project"
STRAT="${BASE}/strategic_tools"
OUT="${BASE}/final_output"
LOG="${OUT}/priority_run_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$OUT"
cd "$BASE"

echo "═══════════════════════════════════════════════"
echo "⚡ YESQUIDPRO: LEGYC PRIORITY TASK RUNNER"
echo "═══════════════════════════════════════════════"
echo "$(date -Iseconds)" | tee "$LOG"

# ────────────────────────────────────────────────
# 1️⃣ VERIFY LETTERS
# ────────────────────────────────────────────────
echo "[1/3] Checking preservation letters..." | tee -a "$LOG"
for FILE in "${STRAT}/preservation/"*.txt; do
  [ -f "$FILE" ] || continue
  echo "   ✓ Found $(basename "$FILE")" | tee -a "$LOG"
done

# ────────────────────────────────────────────────
# 2️⃣ EXPORT COPIES (TEXT SHARE)
# ────────────────────────────────────────────────
echo "[2/3] Exporting printable copies..." | tee -a "$LOG"
for FILE in "${STRAT}/preservation/"*.txt; do
  [ -f "$FILE" ] || continue
  NAME=$(basename "${FILE%.txt}")
  TARGET="${OUT}/${NAME}_print.txt"
  cp "$FILE" "$TARGET"
  echo "   ✓ Copy ready: $TARGET" | tee -a "$LOG"
  termux-share -a send -c "text/plain" "$TARGET" || true
done

# ────────────────────────────────────────────────
# 3️⃣ RUN DAMAGES CALCULATOR
# ────────────────────────────────────────────────
CALC="${STRAT}/damages/damages_calculator.py"
echo "[3/3] Running damages calculator..." | tee -a "$LOG"
if [ -f "$CALC" ]; then
  python3 "$CALC" | tee -a "$LOG"
  cp "${STRAT}/damages/damages_report.json" "$OUT/" 2>/dev/null || true
  echo "   ✓ Damages report stored in $OUT/" | tee -a "$LOG"
else
  echo "⚠️  Damages calculator not found." | tee -a "$LOG"
fi

echo "═══════════════════════════════════════════════" | tee -a "$LOG"
echo "✅ YESQUIDPRO RUN COMPLETE — $(date -Iseconds)" | tee -a "$LOG"
echo "Log saved to: $LOG"
echo "═══════════════════════════════════════════════"
