#!/data/data/com.termux/files/usr/bin/bash
# C25 BUILD TRAINER AGENT
# Trains on all repo commit history — builds intelligence report
C25_HOME="$HOME/constellation25"
BASE="$HOME/github-repos/Constillation25"
REPORT="$BASE/_reports/build_intelligence.md"
MANIFEST="$C25_HOME/logs/totalrecall_manifest.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }
sha() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

mkdir -p "$BASE/_reports"
echo "[$(ts)] [BUILD_TRAINER] START"

{
echo "# C25 BUILD INTELLIGENCE REPORT"
echo "Generated: $(ts) | Operator: u0_a510"
echo ""
echo "## CANONICAL PRINCIPLE"
echo "> AI may propose. Only a human may execute."
echo ""
echo "## REPO TIMELINE"
echo ""

# Chronological across all repos
for repo in "$HOME/github-repos"/*/; do
  name=$(basename "$repo")
  count=$(git -C "$repo" rev-list --count HEAD 2>/dev/null || echo 0)
  first=$(git -C "$repo" log --oneline --reverse 2>/dev/null | head -1)
  last=$(git -C "$repo" log --oneline 2>/dev/null | head -1)
  echo "### $name (commits: $count)"
  echo "- FIRST: $first"
  echo "- LAST:  $last"
  echo ""
done

echo "## SHA256 ANCHOR"
echo "SHA256: $(sha "BUILD_INTELLIGENCE_$(ts)")"
} > "$REPORT"

SHA=$(sha "TRAINER_$(ts)")
echo "[$(ts)] [BUILD_TRAINER] COMPLETE → $REPORT SHA256:$SHA" >> "$MANIFEST"
echo "Report: $REPORT"
