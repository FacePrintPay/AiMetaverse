#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
BASE="$HOME/github-repos/Constillation25"
source "$BASE/_agents/claude_api.sh"
MANIFEST="$BASE/_build/manifest.json"
GRAPH="$BASE/_build/dependency_graph.json"
REPORT="$BASE/_reports/build_intelligence.md"
LOG="$BASE/_logs/trainer.log"

echo "[TRAINER] $(date)" | tee "$LOG"

CONTEXT=$(python3 << PYEOF
import json,os
m=json.load(open("$MANIFEST"))
g=json.load(open("$GRAPH")) if os.path.exists("$GRAPH") else {}
lines=[]
lines.append(f"REPOS: {len(m['repos'])}  FILES: {m['total_files']}")
for repo,info in m["repos"].items():
    lines.append(f"\n{repo}")
    lines.append(f"  stack: {', '.join(info['stack'])}")
    lines.append(f"  files: {info['file_count']}")
    refs=info.get('cross_repo_refs',[])
    if refs: lines.append(f"  refs:  {', '.join(refs)}")
lines.append("\nBUILD ORDER:")
for i,r in enumerate(g.get("execution_order",[]),1):
    lines.append(f"  {i}. {r}")
print('\n'.join(lines))
PYEOF
)

ANALYSIS=$(claude "You are the build intelligence for Constellation25, FacePrintPay's vertically integrated AI platform.

UNIFIED BUILD MAP:
$CONTEXT

Deliver a technical briefing covering:
## 1. SYSTEM ARCHITECTURE — what is FacePrintPay building across these repos?
## 2. INTEGRATION GAPS — what cross-repo connections are broken or missing?
## 3. CRITICAL PATH — which repos are load-bearing for the whole build?
## 4. NEXT AGENT CYCLE — what should each agent prioritize next?
## 5. BUILD HEALTH SCORE — rate the unified build 1-10 with reasoning

Be specific and actionable.")

cat > "$REPORT" << MDEOF
# Constellation25 Build Intelligence
**Date:** $(date)
**Repos:** $(python3 -c "import json; print(len(json.load(open('$MANIFEST'))['repos']))" 2>/dev/null)

---
$ANALYSIS

---
## Raw Build Map
\`\`\`
$CONTEXT
\`\`\`
MDEOF

echo "[TRAINER] Report → $REPORT" | tee -a "$LOG"
echo "✓ BUILD TRAINER complete — read: cat $REPORT"
