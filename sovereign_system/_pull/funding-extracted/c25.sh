#!/data/data/com.termux/files/usr/bin/bash

C25="$HOME/constellation25"
LOGS="$C25/logs"

clear
echo ""
echo "  ██████╗ ██████╗ ███╗   ██╗███████╗████████╗███████╗██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗██████╗ ███████╗"
echo " ██╔════╝██╔═══██╗████╗  ██║██╔════╝╚══██╔══╝██╔════╝██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║╚════██╗██╔════╝"
echo " ██║     ██║   ██║██╔██╗ ██║███████╗   ██║   █████╗  ██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║ █████╔╝███████╗"
echo " ██║     ██║   ██║██║╚██╗██║╚════██║   ██║   ██╔══╝  ██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║██╔═══╝ ╚════██║"
echo " ╚██████╗╚██████╔╝██║ ╚████║███████║   ██║   ███████╗███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████╗███████║"
echo "  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝"
echo ""
echo "                                    🌌  S O V E R E I G N  A G E N T  S Y S T E M  🌌"
echo "                                              25 Planetary Agents · Local-First"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TS=$(date "+%Y-%m-%d %H:%M:%S %Z")
SHA=$(echo "c25-run-$TS-$$" | sha256sum | cut -d' ' -f1)

echo "  Operator  : u0_a510"
echo "  Timestamp : $TS"
echo "  SHA256    : $SHA"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Agent status ─────────────────────────────────────────────
AGENTS=(earth mercury venus mars jupiter saturn uranus neptune pluto luna
        sol sirius vega rigel pleiades orion hydra lyra cygnus andromeda
        perseus cassiopeia aquila draco fomalhaut)

RUNNING=0; DOWN=0
for NAME in "${AGENTS[@]}"; do
  PID_FILE="$C25/agents/$NAME.pid"
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      RUNNING=$((RUNNING+1))
    else
      DOWN=$((DOWN+1))
    fi
  else
    DOWN=$((DOWN+1))
  fi
done

PENDING=$(find "$C25/tasks" -name "*.json" 2>/dev/null | wc -l)
DONE=$(find "$C25/tasks" -name "*.done" 2>/dev/null | wc -l)
LOG_LINES=$(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)
MANIFEST_LINES=$(wc -l < "$LOGS/totalrecall_manifest.log" 2>/dev/null || echo 0)
MCP=$(pgrep -f mcp-stdlib.py > /dev/null 2>&1 && echo "🟢 RUNNING" || echo "🔴 STOPPED")

echo "  AGENTS      🟢 $RUNNING up   🔴 $DOWN down   (25 total)"
echo "  TASKS       📋 $PENDING pending   ✅ $DONE done"
echo "  LOG         📜 $LOG_LINES entries"
echo "  TOTALRECALL 🔐 $MANIFEST_LINES anchors"
echo "  MCP SERVER  $MCP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  COMMANDS:"
echo "  [l] liftoff      — start all 25 agents + MCP"
echo "  [s] status       — full anchor heartbeat"
echo "  [t] tail log     — live log stream"
echo "  [q] queue task   — queue_task.sh [agent] [action] [target]"
echo "  [r] report       — cassiopeia status report"
echo "  [v] verify       — system verify"
echo "  [m] manifest     — last 20 TotalRecall entries"
echo "  [x] exit"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while true; do
  printf "  c25> "
  read -r CMD ARGS

  case "$CMD" in
    l|liftoff)
      echo ""
      bash "$C25/constellation25_liftoff.sh"
      ;;
    s|status)
      echo ""
      bash "$C25/c25_anchor.sh"
      ;;
    t|tail)
      echo ""
      echo "  Streaming log — Ctrl+C to stop"
      echo ""
      tail -f "$LOGS/constellation25.log"
      ;;
    q|queue)
      echo ""
      bash "$C25/queue_task.sh" $ARGS
      ;;
    r|report)
      echo ""
      cat "$C25/reports/status_report.txt" 2>/dev/null || echo "  No report yet — wait ~5 min after liftoff"
      ;;
    v|verify)
      echo ""
      bash "$C25/verify.sh"
      ;;
    m|manifest)
      echo ""
      tail -20 "$LOGS/totalrecall_manifest.log" 2>/dev/null || echo "  No manifest yet"
      ;;
    x|exit|quit)
      echo ""
      echo "  🌌 Constellation25 standing by. Agents continue running."
      echo ""
      exit 0
      ;;
    "")
      ;;
    *)
      echo "  Unknown command: $CMD"
      ;;
  esac
  echo ""
done
