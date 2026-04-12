#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

task_file="$1"

ts="$(date '+%Y-%m-%d %H:%M:%S')"
msg="$(jq -r '.message // ""' "$task_file")"

echo "$ts [agent_valuation] handled task."
echo "Message: $msg"
