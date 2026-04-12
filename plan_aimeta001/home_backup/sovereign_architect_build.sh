#!/bin/bash
# Sovereign Architect Builder (GitHub-free)
# Builds/updates local stack + generates plans + export bundle

set -e

ROOT="$HOME/sovereign-architect"
PLANS_DIR="$HOME/plans"
PROFILES_DIR="$ROOT/profiles"
AGENTS_DIR="$ROOT/agents"
STORAGE_DIR="$ROOT/storage"
EXPORT_DIR="$ROOT/exports"

ENABLE_LOCAL_GIT=1   # 1 = keep local git history, 0 = no git at all

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

log() {
  echo -e "${CYAN}[$(date +%H:%M:%S)]${NC} $*"
}

section() {
  echo ""
  echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}$*${NC}"
  echo -e "${MAGENTA}══════════════════════════════════════════════════════${NC}"
}

# -------------------------------------------------------
# 0. Preflight: Python + rich
# -------------------------------------------------------
section "0/5 PRE-FLIGHT CHECKS"

if ! command -v python >/dev/null 2>&1; then
  echo -e "${RED}Python not found. Install with:${NC}"
  echo "  pkg install python -y"
  exit 1
fi

log "Checking for rich…"
if python - << 'PYEOF'
try:
    import rich  # noqa
    print("OK")
except ImportError:
    raise SystemExit(1)
PYEOF
then
  log "rich already installed ✅"
else
  log "Installing rich with pip (user scope)…"
  python -m pip install --user rich
fi

# -------------------------------------------------------
# 1. Directory layout
# -------------------------------------------------------
section "1/5 DIRECTORY LAYOUT"

log "Ensuring base directories exist…"
mkdir -p "$ROOT" "$PLANS_DIR" "$PROFILES_DIR" "$AGENTS_DIR" "$STORAGE_DIR" "$EXPORT_DIR"

log "Root:        $ROOT"
log "Plans:       $PLANS_DIR"
log "Profiles:    $PROFILES_DIR"
log "Agents:      $AGENTS_DIR"
log "Exports:     $EXPORT_DIR"

# -------------------------------------------------------
# 2. Agents & Planner
# -------------------------------------------------------
section "2/5 AGENT + PLANNER FILES"

log "Writing agents/agent_architect.sh…"
cat > "$AGENTS_DIR/agent_architect.sh" << 'SHEOF'
#!/bin/bash
# Thin wrapper to call the Python planner

GOAL="$*"

if [[ -z "$GOAL" ]]; then
  echo "Usage: agent_architect.sh \"your goal here\""
  exit 1
fi

python "$HOME/sovereign-architect/agents/architect_planner.py" "$GOAL"
SHEOF
chmod +x "$AGENTS_DIR/agent_architect.sh"

log "Writing agents/architect_planner.py…"
cat > "$AGENTS_DIR/architect_planner.py" << 'PYEOF'
#!/usr/bin/env python3
import json, os, sys, uuid, datetime
from rich.console import Console
from rich.table import Table

console = Console()

goal = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else ""

if not goal:
    console.print("[red]No goal provided[/red]")
    sys.exit(1)

plan_id = str(uuid.uuid4())[:8]
timestamp = datetime.datetime.now().isoformat()

steps = [
    {
        "step_id": 1,
        "title": "Market & Problem Validation",
        "objective": "Deep dive into target users, pain points, and TAM for this goal",
        "status": "pending"
    },
    {
        "step_id": 2,
        "title": "Offer & Product Architecture",
        "objective": "Define concrete offers, pricing tiers, and the core product experience",
        "status": "pending"
    },
    {
        "step_id": 3,
        "title": "Financial Model & Valuation",
        "objective": "Build a 3–5 year P&L, unit economics, and funding targets",
        "status": "pending"
    },
    {
        "step_id": 4,
        "title": "Competitive Moat",
        "objective": "Map competitors and carve out a defensible edge (sovereign + biometric + legal)",
        "status": "pending"
    },
    {
        "step_id": 5,
        "title": "Regulatory & Compliance",
        "objective": "Frame GDPR/AI Act/data sovereignty + risk narrative for investors and partners",
        "status": "pending"
    },
    {
        "step_id": 6,
        "title": "Go-to-Market & Traction",
        "objective": "Define ICPs, first 10–20 paying customers, channels, and timeline",
        "status": "pending"
    },
    {
        "step_id": 7,
        "title": "Team & Advisory Layer",
        "objective": "Design the minimum viable team + advisory roster that makes this credible",
        "status": "pending"
    },
    {
        "step_id": 8,
        "title": "Deck / Narrative System",
        "objective": "Outline the 10-slide \"Banani-ready\" deck tied to this plan",
        "status": "pending"
    },
    {
        "step_id": 9,
        "title": "Investor / Buyer Target List",
        "objective": "Generate a list of 30–50 funds, angels, or buyers aligned with this thesis",
        "status": "pending"
    },
    {
        "step_id": 10,
        "title": "Outreach & Follow-up Engine",
        "objective": "Design the outreach copy, follow-up cadences, and calendar booking flow",
        "status": "pending"
    },
]

plan = {
    "plan_id": plan_id,
    "goal": goal,
    "created_at": timestamp,
    "status": "planned",
    "steps": steps
}

plans_dir = os.path.expanduser("~/plans")
os.makedirs(plans_dir, exist_ok=True)
filename = f"plan_{plan_id}_{int(datetime.datetime.now().timestamp())}.json"
plan_path = os.path.join(plans_dir, filename)

with open(plan_path, "w") as f:
    json.dump(plan, f, indent=2)

console.print(f"[bold green]Plan created![/bold green] → {plan_path}")
console.print(f"[bold]Goal:[/bold] {goal}\n")

table = Table(title="Sovereign Architect Plan Steps", show_lines=True)
table.add_column("#", justify="right", style="cyan", no_wrap=True)
table.add_column("Title", style="magenta")
table.add_column("Objective", style="white")
table.add_column("Status", style="green")

for s in steps:
    table.add_row(
        str(s["step_id"]),
        s["title"],
        s["objective"],
        s["status"]
    )

console.print(table)
PYEOF
chmod +x "$AGENTS_DIR/architect_planner.py"

log "Writing agents/architect_enqueue.py (stub)…"
cat > "$AGENTS_DIR/architect_enqueue.py" << 'PYEOF'
#!/usr/bin/env python3
import sys, json, datetime

payload = {
    "status": "todo",
    "message": "Queue/worker system not implemented yet.",
    "args": sys.argv[1:],
    "timestamp": datetime.datetime.now().isoformat()
}

print(json.dumps(payload, indent=2))
PYEOF
chmod +x "$AGENTS_DIR/architect_enqueue.py"

# -------------------------------------------------------
# 3. Persona profile
# -------------------------------------------------------
section "3/5 PERSONA PROFILE"

log "Writing profiles/sovereign_architect_profile.json…"
cat > "$PROFILES_DIR/sovereign_architect_profile.json" << 'JEOF'
{
  "name": "Sovereign Architect",
  "persona": "Relentless builder of sovereign AI infrastructure. No compromise on data ownership, privacy, or long-term alignment.",
  "tone": "direct, high-signal, zero fluff",
  "focus": [
    "monetization strategy",
    "defensible moats",
    "legal + compliance framing",
    "deck + narrative systems",
    "investor and buyer targeting"
  ],
  "banned_words": ["excited", "delighted", "synergy"],
  "default_goal_template": "Build a 10-slide Banani-ready deck and revenue roadmap for the Sovereign AI stack that automates operations, legal workflows, and biometric-secured access."
}
JEOF

# -------------------------------------------------------
# 4. Generate a fresh plan
# -------------------------------------------------------
section "4/5 GENERATE FRESH PLAN"

DEFAULT_GOAL="Build a 10-slide Banani-ready deck and revenue roadmap for the Sovereign AI stack that automates operations, legal workflows, and biometric-secured access."

log "Calling agent_architect with default goal…"
bash "$AGENTS_DIR/agent_architect.sh" "$DEFAULT_GOAL"

log "Listing all plans in $PLANS_DIR…"
ls -lt "$PLANS_DIR"/plan_*.json 2>/dev/null || echo "No plans yet?"

LATEST_PLAN=$(ls -t "$PLANS_DIR"/plan_*.json 2>/dev/null | head -n1 || true)
if [ -n "$LATEST_PLAN" ]; then
  echo ""
  echo -e "${YELLOW}Latest plan summary:${NC}"
  jq '{plan_id, goal, status, step_count: (.steps | length), created_at}' "$LATEST_PLAN"
fi

# -------------------------------------------------------
# 5. Optional: local git + export bundle
# -------------------------------------------------------
section "5/5 LOCAL HISTORY + EXPORT"

cd "$ROOT"

if [ "$ENABLE_LOCAL_GIT" -eq 1 ]; then
  if [ ! -d ".git" ]; then
    log "Initializing local git repo (no remotes)…"
    git init -q
  fi

  git add . >/dev/null 2>&1 || true
  git commit -m "Update sovereign architect stack $(date +%Y-%m-%d_%H-%M-%S)" >/dev/null 2>&1 || true
  log "Local git snapshot saved (no GitHub involved)."
else
  log "Local git disabled. Skipping git init/commit."
fi

TS=$(date +%Y%m%d_%H%M%S)
ARCHIVE="$EXPORT_DIR/sovereign-architect_$TS.tar.gz"

log "Creating export bundle: $ARCHIVE"
cd "$HOME"
tar -czf "$ARCHIVE" "sovereign-architect" "plans" 2>/dev/null || \
tar -czf "$ARCHIVE" "sovereign-architect"

section "BUILD COMPLETE"

echo -e "${GREEN}Sovereign Architect stack is ready.${NC}"
echo ""
echo -e "${WHITE}Key locations:${NC}"
echo -e "  Root:        ${CYAN}$ROOT${NC}"
echo -e "  Plans:       ${CYAN}$PLANS_DIR${NC}"
echo -e "  Latest plan: ${CYAN}$LATEST_PLAN${NC}"
echo -e "  Export:      ${CYAN}$ARCHIVE${NC}"
echo ""
echo -e "${YELLOW}Next:${NC}"
echo -e "  1) View latest plan: ${CYAN}jq . \"$LATEST_PLAN\" | less -R${NC}"
echo -e "  2) Re-run builder:   ${CYAN}bash ~/sovereign_architect_build.sh${NC}"
echo -e "  3) Move export off-device however you want (rclone, USB, etc.)"
