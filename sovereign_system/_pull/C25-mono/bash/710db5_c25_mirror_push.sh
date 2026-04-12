#!/bin/bash
# C25 MIRROR — Push all FacePrintPay repos to Constillation25 org
TOKEN=$(gh auth token)
ORG="Constillation25"
LOG="$HOME/C25_MIRROR_$(date +%Y%m%d_%H%M%S).log"
SUCCESS=0; FAILED=0; SKIPPED=0

# Third party repos to skip
SKIP="jpegoptim|sqlmap|tergent|sovereign-sdk|LiME|Ultimate-Termux|504ensics|Sovereign-Labs|sqlmapproject|ItsMeAbhishek|tjko|Bhai4You"

echo "🌌 C25 MIRROR TO $ORG — $(date)" | tee "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"

while IFS='|' read -r repo remote; do
  repo=$(echo "$repo" | xargs)
  remote=$(echo "$remote" | xargs)

  # Skip third party
  if echo "$remote" | grep -qE "$SKIP"; then
    echo "⚠ SKIP (3rd party): $repo" | tee -a "$LOG"
    ((SKIPPED++))
    continue
  fi

  # Skip already on Constillation25
  if echo "$remote" | grep -q "Constillation25"; then
    echo "✅ ALREADY C25: $repo" | tee -a "$LOG"
    ((SKIPPED++))
    continue
  fi

  # Get repo name
  reponame=$(basename "$repo")

  echo -e "\n📁 $reponame" | tee -a "$LOG"
  cd "$repo" 2>/dev/null || { echo "  ✗ Can't access" | tee -a "$LOG"; ((FAILED++)); continue; }

  # Create repo on Constillation25 org if doesn't exist
  gh repo create "$ORG/$reponame" --private --source=. --remote=c25 2>/dev/null || \
  git remote set-url c25 "https://$TOKEN@github.com/$ORG/$reponame.git" 2>/dev/null || \
  git remote add c25 "https://$TOKEN@github.com/$ORG/$reponame.git" 2>/dev/null

  # Commit any uncommitted changes
  if ! git diff --quiet 2>/dev/null || \
     ! git diff --cached --quiet 2>/dev/null || \
     [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
    git add -A 2>/dev/null
    git commit -m "C25 Empire sync $(date +%Y-%m-%d)" 2>/dev/null
    echo "  ✓ Committed changes" | tee -a "$LOG"
  fi

  # Push to Constillation25
  branch=$(git branch --show-current 2>/dev/null || echo "main")
  if git push c25 "$branch" --force 2>&1 | tail -2 | tee -a "$LOG"; then
    echo "  ✅ Mirrored to $ORG/$reponame" | tee -a "$LOG"
    ((SUCCESS++))
  else
    echo "  ✗ Failed: $reponame" | tee -a "$LOG"
    ((FAILED++))
  fi

  sleep 2

done < <(bash ~/c25_remote_check.sh 2>/dev/null)

echo "" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "✅ Mirrored: $SUCCESS" | tee -a "$LOG"
echo "✗  Failed:   $FAILED" | tee -a "$LOG"
echo "⚠  Skipped:  $SKIPPED" | tee -a "$LOG"
echo "🌌 C25 Mirror complete — $(date)" | tee -a "$LOG"
