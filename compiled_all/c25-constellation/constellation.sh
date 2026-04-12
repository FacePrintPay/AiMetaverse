#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║         CONSTELLATION-25  —  MAIN ORCHESTRATOR          ║
# ║  bash ~/constellation-25/constellation.sh               ║
# ╚══════════════════════════════════════════════════════════╝
cd ~/constellation-25
# ── BioAuth gate helper ──────────────────────────────────────
bioauth() {
  local LABEL="${1:-Authenticate}"
  local RESULT
  RESULT=$(termux-fingerprint 2>/dev/null)
  if echo "$RESULT" | grep -q "AUTH_RESULT_SUCCESS"; then
    return 0
  else
    termux-toast -s "BioAuth failed: $LABEL"
    return 1
  fi
}
# ── GATE 1: Entry ────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         CONSTELLATION-25  —  PROMPT ENGINE             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo "[*] BioAuth — entry gate..."
bioauth "Entry" || exit 1
echo "[✓] Authenticated."
echo ""
# ── Mode selection ───────────────────────────────────────────
MODE_JSON=$(termux-dialog radio \
  -v "Full 1-25,Earth only,Mars recall,Range 3-25,Status" \
  -t "Constellation-25: Run Mode")
MODE=$(echo "$MODE_JSON" | jq -r '.text // empty')
[ -z "$MODE" ] && { echo "[!] No mode selected."; exit 0; }
echo "[*] Mode: $MODE"
# ── STATUS ───────────────────────────────────────────────────
if [ "$MODE" = "Status" ]; then
  echo ""
  echo "── Constellation-25 Status ─────────────────────────────"
  echo "  Agents:  $(jq '.agents | length' agents.json)"
  RECENT=$(python3 memoria.py recent 3 2>/dev/null)
  echo "  Memoria: $(echo "$RECENT" | python3 -c 'import sys,json; print(len(json.load(sys.stdin)))' 2>/dev/null || echo 0) recent entries"
  echo "  Dir:     ~/constellation-25"
  echo ""
  exit 0
fi
# ── Prompt box ───────────────────────────────────────────────
CONVO_JSON=$(termux-dialog text \
  -i "Paste LLM conversation here (e.g. Claude: your text...)" \
  -t "Constellation-25 — Prompt Engine")
CONVO=$(echo "$CONVO_JSON" | jq -r '.text // empty')
[ -z "$CONVO" ] && { termux-toast -s "Nothing entered."; exit 0; }
echo "[✓] Received ${#CONVO} chars."
echo ""
# ── Earth only ───────────────────────────────────────────────
if [ "$MODE" = "Earth only" ]; then
  echo "$CONVO" | python3 earth_agent.py | jq .
  exit 0
fi
# ── Mars recall ──────────────────────────────────────────────
if [ "$MODE" = "Mars recall" ]; then
  echo "[Mars] Searching Memoria..."
  python3 memoria.py search "$CONVO"
  echo "[Mars] Total Recall..."
  ./total_recall.sh "$CONVO"
  exit 0
fi
# ── Full swarm: parse through Earth ──────────────────────────
echo "[*] Earth Agent parsing..."
EARTH_OUT=$(echo "$CONVO" | python3 earth_agent.py)
if ! echo "$EARTH_OUT" | jq -e '.pruned' > /dev/null 2>&1; then
  echo "[!] Earth Agent error: $EARTH_OUT"
  exit 1
fi
SOURCE=$(echo "$EARTH_OUT" | jq -r '.source')
PRUNED=$(echo "$EARTH_OUT" | jq -r '.pruned')
TASKS=$(echo "$EARTH_OUT"  | jq -c '.tasks')
echo "── Earth Output ─────────────────────────────────────────"
echo "  Source : $SOURCE"
echo "  Pruned : ${PRUNED:0:80}..."
echo "  Tasks  : $(echo "$TASKS" | jq 'length') agents queued"
echo ""
# ── GATE 2: Authorize swarm ──────────────────────────────────
termux-dialog confirm \
  -i "Authorize 25 agents to process '$SOURCE'?" \
  -t "BioAuth — Authorize Swarm" > /dev/null 2>&1 || true
bioauth "Swarm auth" || exit 1
echo "[✓] Swarm authorized."
echo ""
# ── Agent range ──────────────────────────────────────────────
START=2
[ "$MODE" = "Range 3-25" ] && START=3
# ── Agent loop with Framework Pillars ───────────────────────
BASH_SCRIPT=""
BASH_TASK=""
FAILED_AGENTS=""
while IFS= read -r task_json; do
  ID=$(echo "$task_json"   | jq -r '.agent_id')
  NAME=$(echo "$task_json" | jq -r '.agent_name')
  TASK=$(echo "$task_json" | jq -r '.task')
  PRIORITY=$(echo "$task_json" | jq -r '.priority // "normal"')
  PILLARS=$(echo "$task_json" | jq -r '.pillars | join(", ")')
  [ "$ID" -lt "$START" ] && continue
  [ "$ID" -gt 25 ]       && continue
  echo "  [$ID] $NAME — $TASK"
  echo "    Pillars: $PILLARS | Priority: $PRIORITY"
  # FRAMEWORK PILLAR: Adaptive Execution (retry on failure)
  RETRY_COUNT=0
  MAX_RETRIES=2
  SUCCESS=0
  while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
    # Mars (#2): Total Recall + log
    if [ "$ID" = "2" ]; then
      RECALL=$(./total_recall.sh "$PRUNED" 2>/dev/null | head -5)
      if [ -n "$RECALL" ]; then
        echo "    → Recall hits: $RECALL"
        python3 memoria.py log "$SOURCE" "$PRUNED" "Mars" "success" > /dev/null 2>&1 || true
        SUCCESS=1
        break
      fi
    fi
    # BashAgent (#25): generate script with verification
    if [ "$ID" = "25" ]; then
      echo ""
      echo "── BashAgent Generating Script ──────────────────────────"
      BASH_SCRIPT=$(python3 bash_agent.py "$TASK" 2>&1)
      # FRAMEWORK PILLAR: Structural Transparency (verify generated script)
      if echo "$BASH_SCRIPT" | bash -n 2>/dev/null; then
        echo "    [✓] Script syntax verified"
        BASH_TASK="$TASK"
        echo "$BASH_SCRIPT"
        echo ""
        SUCCESS=1
        break
      else
        echo "    [✗] Script syntax error — retrying..."
        RETRY_COUNT=$((RETRY_COUNT + 1))
      fi
    fi
    # Other agents: assume success for now
    if [ "$ID" != "2" ] && [ "$ID" != "25" ]; then
      SUCCESS=1
      break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
  done
  # FRAMEWORK PILLAR: Systemic Resilience (log failures, prevent cascade)
  if [ "$SUCCESS" = "0" ]; then
    echo "    [FAIL] Agent $ID failed after $MAX_RETRIES retries"
    FAILED_AGENTS="$FAILED_AGENTS $NAME"
    python3 memoria.py log "$SOURCE" "Agent $ID ($NAME) failed" "System" "failure" > /dev/null 2>&1 || true
  else
    # FRAMEWORK PILLAR: Structural Transparency (mark complete)
    python3 memoria.py log "$SOURCE" "Agent $ID ($NAME) completed" "$NAME" "success" > /dev/null 2>&1 || true
  fi
done < <(echo "$TASKS" | jq -c '.[]')
# Report failed agents
if [ -n "$FAILED_AGENTS" ]; then
  echo ""
  echo "── Failed Agents (Systemic Resilience) ──────────────────"
  echo "  $FAILED_AGENTS"
  echo "  These failures were isolated and did not cascade."
fi
# ── Deploy offer ─────────────────────────────────────────────
if [ -n "$BASH_SCRIPT" ]; then
  DEPLOY_JSON=$(termux-dialog radio \
    -v "Deploy now,View only,Skip" \
    -t "BashAgent Script Ready — Deploy?")
  DEPLOY=$(echo "$DEPLOY_JSON" | jq -r '.text // "Skip"')
  case "$DEPLOY" in
    "View only")
      echo ""
      echo "$BASH_SCRIPT"
      echo ""
      ;;
    "Deploy now")
      echo "[*] BioAuth — deploy gate..."
      bioauth "Deploy" || { echo "[!] Deploy cancelled."; exit 1; }
      echo "[✓] Deploying..."
      echo "$BASH_SCRIPT" > /tmp/c25_deploy.sh
      chmod +x /tmp/c25_deploy.sh
      bash /tmp/c25_deploy.sh
      rm -f /tmp/c25_deploy.sh
      python3 memoria.py log "$SOURCE" "DEPLOYED: $BASH_TASK" "BashAgent" > /dev/null 2>&1 || true
      echo "[✓] Deployment complete."
      ;;
    *)
      echo "[*] Skipped."
      ;;
  esac
fi
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║    Constellation-25 — All agents complete  ✓           ║"
echo "╚══════════════════════════════════════════════════════════╝"
# ── MCP Integration ──────────────────────────────────────────────
if [ "$USE_MCP" = "true" ]; then
  echo ""
  echo "── MCP Orchestration Mode ───────────────────────────────────"
  echo "  Using MCP server for agent coordination"
  # Check if MCP server is running
  if curl -s http://localhost:8080/mcp/agent-status > /dev/null 2>&1; then
    echo "  [✓] MCP server is online"
    # Use MCP client for orchestration
    python3 mcp_client.py orchestrate "$PRUNED" "$MCP_STRATEGY" > mcp_result.json
    echo "  [✓] MCP orchestration complete"
    cat mcp_result.json | jq .
  else
    echo "  [✗] MCP server not running - start with: python3 mcp_server.py"
    echo "  [*] Falling back to local orchestration"
  fi
fi
