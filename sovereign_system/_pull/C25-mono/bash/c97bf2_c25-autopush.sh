#!/data/data/com.termux/files/usr/bin/bash
# C25 AutoPush - Automated push for all repos
# Runs CanisMajor security scan then pushes everything

LOG="$HOME/sovereign_gtp/logs/autopush.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] AutoPush started" >> "$LOG"

PUSHED=0
FAILED=0
SKIPPED=0

push_repo() {
    local dir="$1"
    local name=$(basename "$dir")
    
    [ ! -d "$dir/.git" ] && return
    
    cd "$dir"
    
    # Check for changes
    git add -A 2>/dev/null
    if git diff --cached --quiet 2>/dev/null; then
        SKIPPED=$((SKIPPED + 1))
        return
    fi
    
    # CanisMajor scan first
    ag=CanisMajor bash ~/github-repos/Constillation25/sovereign_gtp/agents/CanisMajor.sh "$dir" 2>/dev/null
    
    # Commit
    git commit -m "C25 autopush: $name - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
    
    # Push
    if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
        echo "✅ $name"
        echo "[$(date '+%H:%M:%S')] PUSHED: $name" >> "$LOG"
        PUSHED=$((PUSHED + 1))
    else
        echo "❌ $name"
        echo "[$(date '+%H:%M:%S')] FAILED: $name" >> "$LOG"
        FAILED=$((FAILED + 1))
    fi
}

echo "🚀 C25 AutoPush - $(date '+%Y-%m-%d %H:%M')"
echo "Scanning all repos for changes..."
echo ""

# Push all repos
for dir in ~/github-repos/*/; do
    push_repo "$dir"
done

# Push nested FacePrintPay repos
for dir in ~/github-repos/FacePrintPay/*/; do
    push_repo "$dir"
done

# Push MyBuyo
push_repo ~/mybuyo-restore

wait

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  🚀 AutoPush Complete                ║"
printf "║  ✅ Pushed:  %-24s║\n" "$PUSHED repos"
printf "║  ❌ Failed:  %-24s║\n" "$FAILED repos"
printf "║  ⏭️  Skipped: %-24s║\n" "$SKIPPED repos (no changes)"
echo "╚══════════════════════════════════════╝"
echo "[$(date '+%H:%M:%S')] Done - Pushed:$PUSHED Failed:$FAILED Skipped:$SKIPPED" >> "$LOG"
