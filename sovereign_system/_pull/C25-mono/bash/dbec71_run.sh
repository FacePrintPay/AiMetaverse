#!/usr/bin/env bash
set -euo pipefail

SYSROOT=$(cat "$HOME/.sysroot")
RUN_ID=$(date +%Y%m%d_%H%M%S)_$$
RUN_DIR="$SYSROOT/runs/$RUN_ID"
RESULT_DIR="$SYSROOT/results/$RUN_ID"

mkdir -p "$RUN_DIR" "$RESULT_DIR"

LOG="$RUN_DIR/run.log"
SUMMARY="$RESULT_DIR/summary.md"

exec > >(tee -a "$LOG") 2>&1

echo "# RUN $RUN_ID" >> "$SUMMARY"
echo "- Started: $(date)" >> "$SUMMARY"
echo "- Command: $@" >> "$SUMMARY"
echo "" >> "$SUMMARY"

"$@" || echo "❌ ERROR" >> "$SUMMARY"

echo "" >> "$SUMMARY"
echo "- Finished: $(date)" >> "$SUMMARY"
echo "- Log: $LOG" >> "$SUMMARY"

ln -s "$RESULT_DIR" "$SYSROOT/results/latest"

echo "✅ RESULT: $RESULT_DIR"
