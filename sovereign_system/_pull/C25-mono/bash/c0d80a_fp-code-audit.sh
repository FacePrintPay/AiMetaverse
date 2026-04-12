#!/bin/bash
# FacePrintPay Code Audit & Deduplication Tool
set -euo pipefail
AUDIT_DIR="$HOME/failed-builds-audit"
mkdir -p "$AUDIT_DIR"
cd "$AUDIT_DIR"
REPOS="videocourts PaThosAi aikre8tive VeRseD_Ai CygNusMaster- blackboxai-1742374192849 blackboxai-1742376990260 AiKre8tive_Sovereign_Genesis PoRTaLed-"
echo "Cloning all failed repos..."
for repo in $REPOS; do
    echo "Cloning $repo..."
    gh repo clone "FacePrintPay/$repo" "$repo" -- --depth 1 2>/dev/null || echo "Skipped $repo"
done
echo "Deduplicating..."
> dedupe-report.txt
for repo in $REPOS; do
    if [ -d "$repo" ]; then
        cd "$repo"
        SIGNATURE=$(find . -type f ! -path '*/.git/*' -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1)
        echo "$SIGNATURE $repo" >> ../dedupe-report.txt
        cd ..
    fi
done
sort dedupe-report.txt | uniq -c | sort -nr > dedupe-groups.txt
echo "Deduplication complete:"
cat dedupe-groups.txt
echo "BlackboxAI Deep Dive:"
for bb in blackboxai-1742374192849 blackboxai-1742376990260; do
    if [ -d "$bb" ]; then
        echo "=== $bb ==="
        cat "$bb/README.md" 2>/dev/null || echo "No README"
        ls "$bb" | head -30
        echo ""
    fi
done
echo "Audit finished. Reports in $AUDIT_DIR"
ls "$AUDIT_DIR"
