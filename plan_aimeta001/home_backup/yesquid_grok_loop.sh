#!/data/data/com.termux/files/usr/bin/bash
# YESQUID • SOVEREIGN–GROK DEMO LOOP v1
# Bridge between:
#   - Termux + Planetary Agents + TotalRecall
#   - X thread with Grok / Luke / investors
#
# This does NOT give Grok system access.
# It just:
#   - Sets up a Swarm "handoff" folder
#   - Logs the conversation
#   - Keeps JSON handshake + metadata
#   - Gives you canned commands + copy/paste flows

set -euo pipefail

YESQUID_HOME="$HOME/YesQuid"
SWARM_DIR="$YESQUID_HOME/swarm"
LOG_DIR="$SWARM_DIR/logs"
HANDSHAKE_JSON="$SWARM_DIR/grok_handshake.json"
THREAD_FILE="$SWARM_DIR/x_thread.txt"
LAST_REPLY_FILE="$SWARM_DIR/last_grok_reply.txt"
LAST_SWARM_FILE="$SWARM_DIR/last_swarm_reply.txt"

MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
  clear
  cat <<EOF
╔══════════════════════════════════════════════════════╗
║        SOVEREIGN • GROK DEMO LOOP  •  v1.0          ║
║                                                      ║
║   Termux  ⟺  Planetary Agents  ⟺  X Thread          ║
║   (You are the secure relay. No remote access.)      ║
╚══════════════════════════════════════════════════════╝
EOF
}

init_loop() {
  banner
  mkdir -p "$SWARM_DIR" "$LOG_DIR"

  # Handshake JSON
  cat > "$HANDSHAKE_JSON" <<'JSON_EOF'
{
  "partner_model": "Grok",
  "partner_humans": [
    "@grok",
    "@lukemetz"
  ],
  "sovereign_owner": "#MrGGTP / CyGel White",
  "ecosystem": {
    "stack": "YesQuid • PaTHos • TotalRecall • VideoCourts • RepoDepo • FacePrintPay",
    "agents_root": "~/YesQuid/agents",
    "totalrecall_engine": "~/TotalRecall/totalrecall_engine.sh",
    "justice_stack": "~/videocourts-justice-stack"
  },
  "loop_protocol": {
    "step_1": "Grok replies on X",
    "step_2": "User pastes Grok reply into last_grok_reply.txt",
    "step_3": "Run: ./yesquid_grok_loop.sh ingest-grok",
    "step_4": "Run: ./yesquid_grok_loop.sh swarm-react",
    "step_5": "Copy swarm reply back to X thread"
  },
  "agents_sample": [
    {"id": "mars", "role": "Compiler / NLP2CODE"},
    {"id": "empirecoord", "role": "Overseer / self-healing"},
    {"id": "ceres", "role": "Monetization / deal flow"},
    {"id": "alfai", "role": "Outreach & partnerships"},
    {"id": "neptune", "role": "Analytics / telemetry"},
    {"id": "saturn", "role": "Security / integrity"}
  ]
}
JSON_EOF

  : > "$THREAD_FILE"
  : > "$LAST_REPLY_FILE"
  : > "$LAST_SWARM_FILE"

  echo -e "${GREEN}[✓] Grok demo loop initialized${NC}"
  echo -e "${CYAN}    Handshake:   $HANDSHAKE_JSON${NC}"
  echo -e "${CYAN}    X thread log:$THREAD_FILE${NC}"
  echo -e "${CYAN}    Last Grok:   $LAST_REPLY_FILE${NC}"
  echo -e "${CYAN}    Last Swarm:  $LAST_SWARM_FILE${NC}"
  echo ""
  echo -e "${YELLOW}Next:${NC}"
  echo "  1) Put your X thread URL at top of: $THREAD_FILE"
  echo "  2) When Grok replies, paste that text into: $LAST_REPLY_FILE"
  echo "  3) Run:  ./yesquid_grok_loop.sh ingest-grok"
  echo "  4) Then: ./yesquid_grok_loop.sh swarm-react"
}

status_loop() {
  banner
  echo -e "${CYAN}STATUS:${NC}"
  echo "  SWARM_DIR:   $SWARM_DIR"
  echo "  Handshake:   $( [ -f "$HANDSHAKE_JSON" ] && echo "present" || echo "missing" )"
  echo "  Thread log:  $( [ -f "$THREAD_FILE" ] && echo "present" || echo "missing" )"
  echo "  Last Grok:   $( [ -f "$LAST_REPLY_FILE" ] && echo "present" || echo "missing" )"
  echo "  Last Swarm:  $( [ -f "$LAST_SWARM_FILE" ] && echo "present" || echo "missing" )"
  echo ""
  echo -e "${YELLOW}Quick tips:${NC}"
  echo "  ./yesquid_grok_loop.sh init         # one-time setup"
  echo "  ./yesquid_grok_loop.sh howto        # usage recap"
}

howto_loop() {
  banner
  cat <<EOF
WORKFLOW • SOVEREIGN ↔ GROK DEMO LOOP
-------------------------------------

1) Start / identify an X thread
   - This is where you're talking to @grok and @lukemetz
   - Put the URL into:
       $THREAD_FILE
   - Example first line:
       https://x.com/yourhandle/status/1234567890

2) When Grok replies on X:
   - Copy his reply (text only, no markup)
   - Paste it into:
       $LAST_REPLY_FILE

3) In Termux, tell the loop you ingested Grok:
   ./yesquid_grok_loop.sh ingest-grok

4) Generate a "Swarm reaction" summary stub:
   ./yesquid_grok_loop.sh swarm-react

   This DOES NOT talk to Grok directly.
   It just:
     - Logs the exchange
     - Creates a concise reply stub in:
         $LAST_SWARM_FILE

5) Copy the swarm reply from:
   $LAST_SWARM_FILE

   and paste it back into the X thread as your reply.

You remain the secure relay.
No external system is given device access.
EOF
}

ingest_grok() {
  banner
  if [ ! -s "$LAST_REPLY_FILE" ]; then
    echo -e "${RED}[!] last_grok_reply.txt is empty${NC}"
    echo "    Paste Grok's latest X reply into:"
    echo "      $LAST_REPLY_FILE"
    exit 1
  fi

  ts="$(date -Iseconds)"
  echo -e "${GREEN}[✓] Ingesting Grok reply at $ts${NC}"

  {
    echo "────────────────────────────────────────"
    echo "[$ts] GROK_REPLY"
    cat "$LAST_REPLY_FILE"
    echo
  } >> "$THREAD_FILE"

  # Also log to a rotating log file
  echo "{\"ts\":\"$ts\",\"source\":\"grok\",\"message\":$(printf '%s' "$(tr '\n' ' ' < "$LAST_REPLY_FILE")" | jq -Rs '.')}" \
    >> "$LOG_DIR/grok_loop.jsonl"

  echo -e "${GREEN}[✓] Logged Grok reply into thread + JSONL log${NC}"
  echo ""
  echo -e "${YELLOW}Next:${NC}"
  echo "  ./yesquid_grok_loop.sh swarm-react"
}

swarm_react() {
  banner
  if [ ! -s "$LAST_REPLY_FILE" ]; then
    echo -e "${RED}[!] No Grok reply loaded in $LAST_REPLY_FILE${NC}"
    exit 1
  fi

  ts="$(date -Iseconds)"

  # We don't "generate" language here (LLM does that in chat),
  # this is a structured stub for you to edit / paste.
  cat > "$LAST_SWARM_FILE" <<EOF
Swarm Reply • $ts

Appreciate you stepping into the Sovereign Swarm loop. 🌀

Under the hood this run is:
- Termux + YesQuid + PaTHos + TotalRecall
- 25 planetary agents (Mars = compiler, Ceres = deal flow, EmpireCoord = self-healing)
- Justice stack (VideoCourts) + evidence-locked RepoDepo

Right now we’re running in “demo loop” mode:
- You reply on X
- I ingest it into Termux
- Swarm agents log + react
- I push the Swarm’s distilled reply back to you

If you’re open, next step is:
short async Groove:
- pick 1 vertical (VideoCourts | FacePrintPay | Agent Swarm infra)
- agree on a tiny integration spec
- ship a minimal live demo and report back to this thread.

Happy to route you a 1-page architecture + repo bundle link next.
EOF

  {
    echo "────────────────────────────────────────"
    echo "[$ts] SWARM_REPLY_STUB"
    cat "$LAST_SWARM_FILE"
    echo
  } >> "$THREAD_FILE"

  echo -e "${GREEN}[✓] Swarm reply stub written to:${NC}"
  echo "    $LAST_SWARM_FILE"
  echo ""
  echo -e "${YELLOW}Next:${NC}"
  echo "  1) Open that file:"
  echo "       nano $LAST_SWARM_FILE"
  echo "     (tweak wording if you want)"
  echo "  2) Copy it and paste as your X reply to Grok."
}

x_reply_template() {
  banner
  cat <<'EOF'
Suggested short X reply (<= 280 chars):

Love that you’re open to it. 🙏

Right now the Sovereign Swarm runs in Termux: 25 agents + TotalRecall + VideoCourts + RepoDepo. I’m wiring a “demo loop” so your replies get ingested into the swarm. I’ll post a live run + 1-page architecture next in-thread.
EOF
}

case "${1:-help}" in
  init)
    init_loop
    ;;
  status)
    status_loop
    ;;
  howto)
    howto_loop
    ;;
  ingest-grok)
    ingest_grok
    ;;
  swarm-react)
    swarm_react
    ;;
  x-template)
    x_reply_template
    ;;
  help|*)
    banner
    cat <<EOF

Usage:
  ./yesquid_grok_loop.sh init         # one-time setup
  ./yesquid_grok_loop.sh status       # show paths and health
  ./yesquid_grok_loop.sh howto        # recap workflow
  ./yesquid_grok_loop.sh ingest-grok  # log latest Grok reply (you paste it)
  ./yesquid_grok_loop.sh swarm-react  # generate swarm reply stub
  ./yesquid_grok_loop.sh x-template   # show short X reply template

EOF
    ;;
esac
