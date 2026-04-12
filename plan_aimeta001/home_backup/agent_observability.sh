#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

task_file="$1"
agent_name="$(basename "$0" .sh)"
ts="$(date '+%Y-%m-%d %H:%M:%S')"
msg="$(jq -r '.message // ""' "$task_file")"

echo "$ts [$agent_name] handled task."
echo "Message: $msg"
