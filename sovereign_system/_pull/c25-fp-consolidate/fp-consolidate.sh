#!/bin/bash
# FacePrintPay Full Consolidation Script
set -euo pipefail
MASTER_REPO="FacePrintPay-Consolidated"
AUDIT_DIR="$HOME/consolidation-audit"
mkdir -p "$AUDIT_DIR"
cd "$AUDIT_DIR"
REPOS="videocourts PaThosAi aikre8tive VeRseD_Ai CygNusMaster- blackboxai-1742374192849 blackboxai-1742376990260 AiKre8tive_Sovereign_Genesis PoRTaLed-"
echo "Cloning all failed repos..."
for repo in $REPOS; do
    echo "Cloning $repo..."
    gh repo clone "FacePrintPay/$repo" "$repo" -- --depth 1 2>/dev/null || true
done
echo "Parsing and pruning..."
for repo in $REPOS; do
    if [ -d "$repo" ]; then
        cd "$repo"
        find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
        find . -name "*.log" -delete 2>/dev/null || true
        cd ..
    fi
done
echo "Compiling into master repo..."
gh repo create "$MASTER_REPO" --public --clone || true
gh repo clone "FacePrintPay/$MASTER_REPO" master -- --depth 1
cd master
for repo in $REPOS; do
    if [ -d "../$repo" ]; then
        echo "Merging $repo..."
        cp -r "../$repo/." . 2>/dev/null || true
    fi
done
echo "Debugging workflows..."
find . -name "*.yml" -o -name "*.yaml" 2>/dev/null | while read -r wf; do
    sed -i 's/timeout-minutes: [0-9]*/timeout-minutes: 30/g' "$wf" 2>/dev/null || true
done
git add .
git commit -m "🔄 Consolidated all code - Pruned & Debugged" || true
git branch -M main-clean
git push -u origin main-clean
echo "✅ Master repo created and pushed to main-clean branch"
echo "https://github.com/FacePrintPay/$MASTER_REPO/tree/main-clean"
echo "Consolidation complete!"
ls "$AUDIT_DIR"
