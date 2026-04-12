#!/usr/bin/env bash
set -euo pipefail
tmux ls 2>/dev/null | awk -F: '/^PA_/ {print $1}' | while read -r s; do
  tmux kill-session -t "$s" || true
done
echo "🛑 Stack stopped."
