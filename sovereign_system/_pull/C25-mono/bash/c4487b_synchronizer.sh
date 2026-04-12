#!/data/data/com.termux/files/usr/bin/bash
# C25 SYNCHRONIZER AGENT
# Syncs all repos, logs to TotalRecall
C25_HOME="$HOME/constellation25"
REPOS="$HOME/github-repos"
LOG="$C25_HOME/logs/synchronizer.log"
MANIFEST="$C25_HOME/logs/totalrecall_manifest.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }
sha() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

echo "[$(ts)] [SYNCHRONIZER] START" | tee -a "$LOG"

synced=0; failed=0
for repo in "$REPOS"/*/; do
  name=$(basename "$repo")
  if git -C "$repo" status > /dev/null 2>&1; then
    git -C "$repo" add -A 2>/dev/null
    git -C "$repo" commit -m "C25 sync: $name - $(date '+%Y-%m-%d %H:%M')" \
      --allow-empty 2>/dev/null
    synced=$((synced+1))
  else
    failed=$((failed+1))
  fi
done

SHA=$(sha "SYNC_${synced}_$(ts)")
echo "[$(ts)] [SYNCHRONIZER] COMPLETE synced:$synced failed:$failed SHA256:$SHA" \
  | tee -a "$LOG" >> "$MANIFEST"
