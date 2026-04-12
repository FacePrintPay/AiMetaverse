#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Change this to the existing repo you want to use:
TARGET_SLUG="FacePrintPay/sovereign-architect"

REMOTE_URL="https://github.com/${TARGET_SLUG}.git"
ROOT="$HOME/TheKre8tive"

log(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
die(){ log "ERROR: $*"; exit 1; }

cd "$ROOT" 2>/dev/null || die "Missing $ROOT. Run your scaffold script first."

if git remote get-url origin >/dev/null 2>&1; then
  log "Updating origin -> $REMOTE_URL"
  git remote set-url origin "$REMOTE_URL"
else
  log "Adding origin -> $REMOTE_URL"
  git remote add origin "$REMOTE_URL"
fi

log "Pushing to $TARGET_SLUG"
if git push -u origin main; then
  log "Push complete: https://github.com/$TARGET_SLUG"
else
  if command -v gh >/dev/null 2>&1; then
    log "Push failed. Checking gh auth..."
    gh auth status >/dev/null 2>&1 || gh auth login
    git push -u origin main
    log "Push complete: https://github.com/$TARGET_SLUG"
  else
    die "Push failed. Install: pkg install gh && gh auth login"
  fi
fi
