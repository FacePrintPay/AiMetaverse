#!/usr/bin/env bash
set -euo pipefail

AGENT="${1:?agent_name required}"
MONO="${2:?monorepo_path required}"

PA="$HOME/PlanetaryAgents"
INBOX="$PA/taskboxes/$AGENT/inbox"
DONE="$PA/taskboxes/$AGENT/done"
FAIL="$PA/taskboxes/$AGENT/fail"
LOG="$PA/logs/${AGENT}.log"

mkdir -p "$INBOX" "$DONE" "$FAIL" "$(dirname "$LOG")"

ts(){ date "+%Y-%m-%d %H:%M:%S"; }
log(){ echo "[$(ts)] [$AGENT] $*" | tee -a "$LOG"; }

run_task_file() {
  local f="$1"
  local base
  base="$(basename "$f")"

  # Ensure LF newlines
  sed -i 's/\r$//' "$f" 2>/dev/null || true

  log "📥 Task picked up: $base"
  log "----- TASK BEGIN -----"
  cat "$f" | sed 's/^/  | /' | tee -a "$LOG"
  log "----- TASK END -------"

  # Execute task in monorepo
  # SECURITY NOTE: tasks are shell scripts. Only drop tasks you trust.
  if ( cd "$MONO" && bash "$f" >>"$LOG" 2>&1 ); then
    log "✅ Task succeeded: $base"
    mv -f "$f" "$DONE/$base"
  else
    log "❌ Task failed: $base"
    mv -f "$f" "$FAIL/$base"
  fi
}

log "🚀 Taskbox runner starting. Inbox=$INBOX Monorepo=$MONO"

# Catch existing tasks first
for f in "$INBOX"/*.task; do
  [ -e "$f" ] || break
  run_task_file "$f"
done

# Watch continuously
inotifywait -m -e close_write,moved_to,create --format "%f" "$INBOX" 2>/dev/null | while read -r name; do
  [[ "$name" == *.task ]] || continue
  run_task_file "$INBOX/$name"
done
