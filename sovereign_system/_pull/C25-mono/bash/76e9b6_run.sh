#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# C25 MASTER DISPATCHER — Constillation25
# Operator: u0_a510
# Canonical: AI proposes. Only a human may execute.
# ═══════════════════════════════════════════════════════════════

BASE="$(cd "$(dirname "$0")" && pwd)"
C25_HOME="$HOME/constellation25"
AGENTS="$BASE/_agents"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "╔══════════════════════════════════════════════════════╗"
echo "║     CONSTILLATION25 — MASTER DISPATCHER             ║"
echo "║     AI proposes. Only a human may execute.          ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

case "${1:-}" in
  --sync)     bash "$AGENTS/synchronizer.sh" ;;
  --train)    bash "$AGENTS/build_trainer.sh" ;;
  --gamma)    bash "$AGENTS/gamma_agent.sh" "${2:-}" ;;
  --scrape)   bash "$AGENTS/scraper_agent.sh" "${2:-}" "${3:-}" ;;
  --obsidian) bash "$AGENTS/obsidian_agent.sh" "${2:-}" "${3:-}" "${4:-}" ;;
  --report)   cat "$BASE/_reports/build_intelligence.md" 2>/dev/null \
                || echo "Run --train first" ;;
  --list)
    echo "AVAILABLE AGENTS:"
    ls "$AGENTS"/*.sh 2>/dev/null | xargs -I{} basename {}
    ;;
  --status)
    echo "C25 STATUS:"
    echo "  MCP:     $(curl -s --max-time 2 http://localhost:3000/health 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin) 2>/dev/null || echo "OFFLINE"; print(d['status'])" 2>/dev/null || echo "OFFLINE")"
    echo "  Repos:   $(ls "$HOME/github-repos" | wc -l)"
    echo "  Agents:  $(ls "$HOME/github-repos/Constillation25/_agents"/*.sh 2>/dev/null | wc -l)"
    echo "  Gamma:   $([ -f "$C25_HOME/gamma.sh" ] && echo 'READY' || echo 'MISSING')"
    echo "  Banana:  $([ -f "$C25_HOME/banana.py" ] && echo 'READY' || echo 'MISSING')"
    echo "  Obsidian:$([ -d "/sdcard/Documents/Obsidian" ] && echo 'MOUNTED' || echo 'NOT MOUNTED')"
    ;;
  --help|*)
    echo "USAGE: bash run.sh [command]"
    echo ""
    echo "  --sync          Sync all repos to GitHub"
    echo "  --train         Build intelligence report from commit history"
    echo "  --gamma <prompt> Run full gamma pipeline"
    echo "  --scrape <url>  Scrape + analyze URL via Ollama"
    echo "  --obsidian      Write to Obsidian vault"
    echo "  --report        Show build intelligence report"
    echo "  --list          List all available agents"
    echo "  --status        Show C25 system status"
    echo ""
    echo "CANONICAL: AI proposes. Only a human may execute."
    ;;
esac
