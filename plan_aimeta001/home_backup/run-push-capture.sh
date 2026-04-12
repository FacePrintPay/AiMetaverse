#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-$HOME/test-repo}"
REMOTE="origin"
BRANCH="main"
OUTDIR="$HOME/push-capture-logs"
mkdir -p "$OUTDIR"
cd "$SOURCE_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
PUSH_LOG="$OUTDIR/push-${TIMESTAMP}.log"
BIO_LOG="$HOME/.git-bio-log"

echo "=== push-capture starting: $TIMESTAMP ===" | tee -a "$PUSH_LOG"
git status --porcelain=2 --branch | tee -a "$PUSH_LOG"
git remote -v | tee -a "$PUSH_LOG"
echo "" | tee -a "$PUSH_LOG"

echo "Running: git push -u $REMOTE $BRANCH" | tee -a "$PUSH_LOG"
( git push -u "$REMOTE" "$BRANCH" ) 2>&1 | tee -a "$PUSH_LOG"
PUSH_EXIT=${PIPESTATUS[0]:-0}

echo "" | tee -a "$PUSH_LOG"
echo "git push exit code: $PUSH_EXIT" | tee -a "$PUSH_LOG"

if [[ -f "$BIO_LOG" ]]; then
    echo "=== biometric audit log ($BIO_LOG) ===" | tee -a "$PUSH_LOG"
    cat "$BIO_LOG" 2>/dev/null | sed -n '1,400p' | tee -a "$PUSH_LOG"
else
    echo "No biometric audit log found at $BIO_LOG" | tee -a "$PUSH_LOG"
fi

echo "Log saved to: $PUSH_LOG"
