#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="andromeda"
REPOS="$C25/repos"
mkdir -p "$REPOS"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  REPO_COUNT=$(find "$REPOS" -maxdepth 1 -type d 2>/dev/null | wc -l)
  for REPO in "$REPOS"/*/; do
    [ -d "$REPO/.git" ] || continue
    BRANCH=$(git -C "$REPO" branch --show-current 2>/dev/null || echo unknown)
    echo "[$TS] [$NAME] REPO_STATUS path:$REPO branch:$BRANCH" >> "$LOGS/constellation25.log"
  done
  echo "[$TS] [$NAME] STATUS:OK repos:$REPO_COUNT" >> "$LOGS/andromeda.log"
  sleep 300
done
