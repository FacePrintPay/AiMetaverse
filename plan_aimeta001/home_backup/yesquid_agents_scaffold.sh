#!/bin/bash
# YESQUID PLANETARY AGENTS SCAFFOLD
# Creates a real on-disk registry + per-agent dirs + stub run scripts
# to be wired into PaTHos / NLP2CODE / orchestrators.

set -euo pipefail

HOME_DIR="${HOME:-/data/data/com.termux/files/home}"

YESQUID_HOME="$HOME_DIR/YesQuid"
AGENTS_ROOT="$YESQUID_HOME/agents"
LOG_ROOT="$YESQUID_HOME/agents-logs"
REGISTRY_FILE="$AGENTS_ROOT/registry.json"

mkdir -p "$YESQUID_HOME" "$AGENTS_ROOT" "$LOG_ROOT"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
  cat << 'EOF'
╔══════════════════════════════════════════════╗
║     YESQUID PLANETARY AGENTS  •  SCAFFOLD   ║
║  25-AGENT REGISTRY · RUN STUBS · LOG PATHS  ║
╚══════════════════════════════════════════════╝
EOF
}

# id|Name|Tagline|Description
AGENTS_DEF=(
"mercury|Mercury|Messenger Node|NLP routing and command parsing between the user, Mars (compiler), and other agents."
"venus|Venus|Creative Engine|Creative and marketing asset generation, social content, and attention engineering."
"earth|Earth|Human-in-the-loop|Governance, approvals, and biometric identity validation checkpoints."
"mars|Mars|Compiler|Full-stack codegen + NLP2CODE execution for repos and build pipelines."
"jupiter|Jupiter|Scaler|Distributed orchestration, queueing, and auto-sharding of workloads."
"saturn|Saturn|Security Sentinel|Integrity, verification, and anti-tampering guard for code and evidence."
"uranus|Uranus|Innovation Lab|R&D sandbox for feature prototyping, experiments, and new flows."
"neptune|Neptune|Analyst|Analytics, telemetry, and insight dashboards across stacks."
"pluto|Pluto|Backup Guardian|Cold storage, redundancy, and archival mirroring."
"sun|sun|Central Command|Top-level orchestrator and activation router for all agents."
"moon|Moon|Narrator|Narration, TTS, story-mode reporting, and explainer output."
"titan|Titan|Deployment Engine|CI/CD, packaging, and multi-target deployment automation."
"eris|Eris|Legal & Compliance|Evidence bundling, manifests, legal packet generation, and policy checks."
"chronos|Chronos|Historian|Timeline reconstruction, log stitching, and time-based correlation."
"ceres|Ceres|Monetization Node|Revenue logic, pricing, checkout flows, and offer packaging."
"callisto|Callisto|Media Engineer|Video/audio clipping, editing, captions, and content preparation."
"alfai|ALFAI|Outreach & Partnerships|Outreach, booking assistance, PR targeting, and relationship tracking."
"explorermars|ExplorerMars|Discovery Engine|Repo scanning, API discovery, and capability cataloging."
"comand|CoManD|Natural Language CLI|Converts natural language ops into executable command sequences."
"slamar|SlamAR|AR / XR Layer|AR/XR scene generation and immersive interaction stubs."
"send2repo|Send2Repo|Sync Layer|Auto-commit and push of generated artifacts into Git repos."
"trickortrakr|TrickorTrakR|Tracking & Watchdog|Location-style tracking of processes, jobs, and modules."
"tailview|TailView|UI Preview|Tailwind/UI preview rendering and quick visual checks."
"mybuyo|MyBuyO|Payments Node|Biometric checkout, store logic, and digital goods handling."
"empirecoord|EmpireCoordinator|Overseer|Self-healing orchestration, fallback routing, and error handling."
)

create_agent() {
  local row="$1"

  IFS='|' read -r id name tagline desc <<<"$row"

  local dir="$AGENTS_ROOT/$id"
  local log_dir="$LOG_ROOT/$id"

  mkdir -p "$dir" "$log_dir"

  # metadata.json
  cat >"$dir/metadata.json" <<EOF
{
  "id": "$id",
  "name": "$name",
  "tagline": "$tagline",
  "description": "$desc",
  "entrypoint": "run.sh",
  "logs_dir": "$log_dir",
  "breadcrumbs": [
    "planetary-agents",
    "sovereign-deck",
    "videocourts-justice-stack",
    "totalrecall",
    "yesquid-nlp2code"
  ],
  "status": "stub",
  "owner": "Kre8tive Konceptz · Sovereign AI",
  "created_at": "$(date -Iseconds 2>/dev/null || date)"
}
EOF

  # run.sh stub
  cat >"$dir/run.sh" <<EOF
#!/bin/bash
# $name Agent - STUB
# ID: $id
# Tagline: $tagline

set -euo pipefail

echo "[$name] agent invoked."
echo "ID: $id"
echo "Mode: stub"
echo "Description: $desc"
echo "Logs: $log_dir"

# TODO:
#  - Wire this into PaTHos / NLP2CODE
#  - Implement real behavior according to specs
#  - Optionally call TotalRecall or other agents

EOF

  chmod +x "$dir/run.sh"

  echo "  - $name ($id) scaffolded at $dir"
}

build_registry() {
  local tmp
  tmp="$(mktemp)"

  for row in "${AGENTS_DEF[@]}"; do
    IFS='|' read -r id name tagline desc <<<"$row"
    local dir="$AGENTS_ROOT/$id"
    local log_dir="$LOG_ROOT/$id"

    cat >>"$tmp" <<EOF
    {
      "id": "$id",
      "name": "$name",
      "tagline": "$tagline",
      "dir": "$dir",
      "log_dir": "$log_dir"
    },
EOF
  done

  {
    echo '{'
    echo '  "version": "1.0",'
    echo '  "generated_at": "'"$(date -Iseconds 2>/dev/null || date)"'",'
    echo '  "root": "'"$AGENTS_ROOT"'",'
    echo '  "logs_root": "'"$LOG_ROOT"'",'
    echo '  "agents": ['
    # remove trailing comma on last element
    sed '$ s/},$/}/' "$tmp"
    echo '  ]'
    echo '}'
  } >"$REGISTRY_FILE"

  rm -f "$tmp"
}

main() {
  banner
  echo -e "${CYAN}Scaffolding planetary agents into:${NC} $AGENTS_ROOT"
  echo ""

  for row in "${AGENTS_DEF[@]}"; do
    create_agent "$row"
  done

  echo ""
  echo -e "${CYAN}Building registry:${NC} $REGISTRY_FILE"
  build_registry

  echo ""
  echo -e "${GREEN}[✓] Planetary agents scaffolded.${NC}"
  echo -e "${GREEN}[✓] Registry:${NC} $REGISTRY_FILE"
  echo -e "${GREEN}[✓] Logs root:${NC} $LOG_ROOT"
  echo ""
  echo "Next typical moves:"
  echo "  - ls \"$AGENTS_ROOT\""
  echo "  - cat \"$AGENTS_ROOT/mars/metadata.json\""
  echo "  - \"$AGENTS_ROOT/mars/run.sh\""
  echo "  - Wire orchestrator (Python/Node) to read registry.json and invoke run.sh per agent"
  echo ""
}

main "$@"
