#!/data/data/com.termux/files/usr/bin/bash
# YESQUID PLANETARY AGENTS • RUN FIXER (CLEAN)
# 25 AGENTS · SIMPLE JSON · NO sed · NO weird quoting

set -euo pipefail

AGENTS_ROOT="$HOME/YesQuid/agents"
LOG_ROOT="$HOME/YesQuid/agents-logs"

mkdir -p "$AGENTS_ROOT" "$LOG_ROOT"

banner() {
  cat << 'EOF'
╔══════════════════════════════════════════════╗
║     YESQUID PLANETARY AGENTS • RUN FIXER    ║
║    25 AGENTS · CLEAN JSON · NO SED ERRORS   ║
╚══════════════════════════════════════════════╝
EOF
}

write_agent_run() {
  local id="$1"
  local name="$2"
  local role="$3"

  local dir="$AGENTS_ROOT/$id"
  mkdir -p "$dir"

  cat > "$dir/run.sh" << EOF
#!/data/data/com.termux/files/usr/bin/bash
# Auto-generated run script for YesQuid agent: $name ($id)
set -euo pipefail

AGENT_ID="$id"
AGENT_NAME="$name"
AGENT_ROLE="$role"

LOG_ROOT="\$HOME/YesQuid/agents-logs"
mkdir -p "\$LOG_ROOT"
LOG_FILE="\$LOG_ROOT/\${AGENT_ID}.log"

TS="\$(date -Iseconds 2>/dev/null || date)"
TASK="\${1:-}"

MSG="Agent \${AGENT_NAME} (\${AGENT_ROLE})"
if [ -n "\$TASK" ]; then
  MSG="\$MSG received task: \$TASK"
else
  MSG="\$MSG heartbeat"
fi

# NOTE: To keep things robust, avoid double quotes in TASK for now.
# This keeps JSON simple without extra escaping logic.

# Log line
printf '{"ts":"%s","agent":"%s","level":"info","message":"%s","extra":{}}\n' \
  "\$TS" "\$AGENT_ID" "\$MSG" >> "\$LOG_FILE"

# Console line
printf '{"ok":true,"agent":"%s","name":"%s","ts":"%s","role":"%s","message":"%s"}\n' \
  "\$AGENT_ID" "\$AGENT_NAME" "\$TS" "\$AGENT_ROLE" "\$MSG"
EOF

  chmod +x "$dir/run.sh"
  echo "  - wrote $dir/run.sh  (role: $role)"
}

main() {
  banner
  echo "Scaffolding / fixing run.sh under: $AGENTS_ROOT"
  echo ""

  write_agent_run "mercury"      "Mercury"           "Messenger / NLP router"
  write_agent_run "venus"        "Venus"             "Creative marketing / resonance"
  write_agent_run "earth"        "Earth"             "Human-in-the-loop governor"
  write_agent_run "mars"         "Mars"              "Compiler / NLP2CODE"
  write_agent_run "jupiter"      "Jupiter"           "Scaler / orchestrator"
  write_agent_run "saturn"       "Saturn"            "Security / integrity"
  write_agent_run "uranus"       "Uranus"            "Innovation lab / R&D"
  write_agent_run "neptune"      "Neptune"           "Analytics / telemetry"
  write_agent_run "pluto"        "Pluto"             "Backup / cold storage"
  write_agent_run "sun"          "Sun"               "Central command router"
  write_agent_run "moon"         "Moon"              "Narrator / TTS"
  write_agent_run "titan"        "Titan"             "Deployment / CI/CD"
  write_agent_run "eris"         "Eris"              "Legal & compliance"
  write_agent_run "chronos"      "Chronos"           "Historian / timeline"
  write_agent_run "ceres"        "Ceres"             "Monetization node"
  write_agent_run "callisto"     "Callisto"          "Media / clips engine"
  write_agent_run "alfai"        "ALFAI"             "Outreach & partnerships"
  write_agent_run "explorermars" "ExplorerMars"      "Discovery / repo & API scanner"
  write_agent_run "comand"       "CoManD"            "Natural language CLI"
  write_agent_run "slamar"       "SlamAR"            "AR / XR layer"
  write_agent_run "send2repo"    "Send2Repo"         "Git sync / Push2Repo"
  write_agent_run "trickortrakr" "TrickorTrakR"      "Tracking & watchdog"
  write_agent_run "tailview"     "TailView"          "UI preview renderer"
  write_agent_run "mybuyo"       "MyBuyO"            "Payments / storefront"
  write_agent_run "empirecoord"  "EmpireCoordinator" "Overseer / self-healing"

  echo ""
  echo "[✓] All agent run.sh scripts rewritten cleanly."
  echo "[✓] Logs root: $LOG_ROOT"
  echo ""
  echo "Examples now:"
  echo "  \$HOME/YesQuid/agents/mars/run.sh \"compile videocourts justice stack\""
  echo "  \$HOME/YesQuid/agents/empirecoord/run.sh \"swarm health check\""
}

main "\$@"
