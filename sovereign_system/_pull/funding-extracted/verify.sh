#!/data/data/com.termux/files/usr/bin/bash
echo "╔══════════════════════════════════════════════╗"
echo "║   CONSTELLATION25 — SYSTEM VERIFY           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
OK=0; FAIL=0

check(){ 
  if [ -e "$2" ]; then
    echo "  ✅ $1"; OK=$((OK+1))
  else
    echo "  ❌ MISSING: $1 ($2)"; FAIL=$((FAIL+1))
  fi
}

C25="$HOME/constellation25"
check "C25 directory"         "$C25"
check "Tasks directory"       "$C25/tasks"
check "Logs directory"        "$C25/logs"
check "Agents directory"      "$C25/agents"
check "MCP server"            "$C25/mcp-stdlib.py"
check "Run agent script"      "$C25/run_agent.sh"
check "Anchor script"         "$C25/c25_anchor.sh"
check "Liftoff script"        "$C25/constellation25_liftoff.sh"
check "Claude Desktop config" "$HOME/.config/Claude/claude_desktop_config.json"
check "Beta guide"            "$C25/BETA_GUIDE.md"

echo ""
echo "  Python3   : $(python3 --version 2>/dev/null || echo MISSING)"
echo "  Bash      : $(bash --version 2>/dev/null | head -1)"
echo "  Port 3000 : $(curl -s --max-time 1 http://localhost:3000/status 2>/dev/null || echo 'not running')"
echo ""
echo "  ✅ Passed : $OK"
echo "  ❌ Failed : $FAIL"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "  🚀 SYSTEM READY FOR BETA LAUNCH"
else
  echo "  ⚠️  Fix missing items before beta launch"
fi
