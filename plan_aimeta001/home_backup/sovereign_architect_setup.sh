 #!/bin/bash
# Sovereign Architect – Full Repo Bootstrapper
# Builds: repo, agent stack, tasks file, manifest, first plan, push to GitHub

set -e

REPO_NAME="sovereign-architect"
REPO_DIR="$HOME/$REPO_NAME"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        SOVEREIGN ARCHITECT BOOTSTRAP        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 0: Update Termux and install everything we need
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 0]${NC} Updating Termux and installing dependencies..."

pkg update -y && pkg upgrade -y
pkg install git gh python jq -y
pip install --upgrade pip
pip install openai rich

echo -e "${GREEN}✓ Base environment ready${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 1: Login to GitHub (device flow)
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 1]${NC} GitHub CLI authentication..."
echo -e "${YELLOW}If not already authenticated, you'll see a URL + code in the next prompt.${NC}"
gh auth status || gh auth login

echo -e "${GREEN}✓ GitHub auth OK${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 2: Create the repo / initialize git
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 2]${NC} Creating local repo at: $REPO_DIR"

mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

if [ ! -d ".git" ]; then
  git init
  git branch -M main
fi

# Create GH repo if not exists
if ! gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  echo -e "${BLUE}→ Creating private GitHub repo: $REPO_NAME${NC}"
  gh repo create "$REPO_NAME" --private --source=. --remote=origin
else
  echo -e "${YELLOW}GitHub repo '$REPO_NAME' already exists, linking remote...${NC}"
  git remote remove origin 2>/dev/null || true
  gh repo view "$REPO_NAME" --json url -q '.url' >/dev/null
  ORIGIN_URL=$(gh repo view "$REPO_NAME" --json url -q '.url')
  git remote add origin "$ORIGIN_URL"
fi

echo -e "${GREEN}✓ Repo initialized and remote linked${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 3: Create folder structure
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 3]${NC} Creating folder structure..."

mkdir -p agents plans profiles storage
mkdir -p docs scripts configs manifests

echo -e "${GREEN}✓ Directories created: agents, plans, profiles, storage, docs, scripts, configs, manifests${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 4: Create agents & planner files
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 4]${NC} Creating Sovereign Architect agent stack..."

cat > agents/agent_architect.sh <<'EOF'
#!/bin/bash
# Sovereign Architect – CLI entrypoint
GOAL="$*"

if [[ -z "$GOAL" ]]; then
  echo "Usage: agent_architect.sh \"your goal here\""
  exit 1
fi

# Run planner from the same directory regardless of CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python "$SCRIPT_DIR/architect_planner.py" "$GOAL"
EOF

cat > agents/architect_planner.py <<'EOF'
#!/usr/bin/env python3
import json, os, sys, uuid, datetime
from rich.console import Console

console = Console()
goal = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else ""

if not goal:
    console.print("[red]No goal provided[/red]")
    sys.exit(1)

plan_id = str(uuid.uuid4())[:8]
timestamp = datetime.datetime.now().isoformat()

plan = {
    "plan_id": plan_id,
    "goal": goal,
    "created_at": timestamp,
    "status": "planned",
    "steps": [
        {"step_id": 1, "title": "Market & Problem Validation", "objective": "Deep dive into pain points and TAM", "status": "pending"},
        {"step_id": 2, "title": "Product Architecture & Roadmap", "objective": "Define SovereignGTP tech stack & MVP", "status": "pending"},
        {"step_id": 3, "title": "Financial Model & Valuation", "objective": "Build 5-year P&L, cap table, $XM pre-money case", "status": "pending"},
        {"step_id": 4, "title": "Competitive Moat Analysis", "objective": "Why we win vs OpenAI/Anthropic/etc", "status": "pending"},
        {"step_id": 5, "title": "Regulatory & Compliance Framing", "objective": "GDPR, AI Act, data sovereignty strategy", "status": "pending"},
        {"step_id": 6, "title": "Go-to-Market & Traction Plan", "objective": "First 10 design partners + revenue timeline", "status": "pending"},
        {"step_id": 7, "title": "Team & Advisors", "objective": "Core team + advisory board", "status": "pending"},
        {"step_id": 8, "title": "Deck Design (Banani-ready)", "objective": "10 slide investor deck, exportable to Notion/Pitch/Gamma", "status": "pending"},
        {"step_id": 9, "title": "Investor Targeting List", "objective": "Top 50 funds + warm intros", "status": "pending"},
        {"step_id": 10,"title": "Outreach Sequences", "objective": "Copy + cadence + calendar links", "status": "pending"}
    ]
}

plans_dir = os.path.expanduser("~/plans")
os.makedirs(plans_dir, exist_ok=True)

plan_file = os.path.join(
    plans_dir,
    f"plan_{plan_id}_{int(datetime.datetime.now().timestamp())}.json"
)

with open(plan_file, "w") as f:
    json.dump(plan, f, indent=2)

console.print(f"[bold green]Plan created![/green] → {plan_file}")
console.print(f"[bold]Goal:[/bold] {goal}")
EOF

cat > agents/architect_enqueue.py <<'EOF'
#!/usr/bin/env python3
# Sovereign Architect – queue stub (future worker system)
import sys, os, json

print("Enqueue system coming soon…")
EOF

echo -e "${GREEN}✓ Agent scripts created${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 5: Make scripts executable
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 5]${NC} Making agent scripts executable..."

chmod +x agents/*.sh agents/*.py || true

echo -e "${GREEN}✓ Agent executables set${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 6: Sovereign profile
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 6]${NC} Creating sovereign architect profile..."

cat > profiles/sovereign_architect_profile.json <<'EOF'
{
  "name": "Sovereign Architect",
  "persona": "Relentless builder of sovereign AI infrastructure. No compromise on data ownership, privacy, or long-term alignment.",
  "tone": "direct, high-signal, slightly autistic, zero fluff",
  "banned_words": ["excited", "delighted", "leverage", "synergy"],
  "focus": [
    "sovereign AI",
    "multi-agent orchestration",
    "evidence-locked systems",
    "Bitcoin anchoring",
    "biometric auth",
    "federal and multi-jurisdictional readiness"
  ]
}
EOF

echo -e "${GREEN}✓ Sovereign profile created${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Extra: Packages Manifest (from your full stack)
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 6B]${NC} Writing packages manifest from Sovereign stack..."

cat > PACKAGES_MANIFEST.md <<'EOF'
# YESQUID / KRE8TIVE KONCEPTZ – PACKAGE MANIFEST
## Sovereign Intelligence Stack • Version 1.0.0

This document enumerates ALL components, systems, agents, and scripts
referenced by the Sovereign Architect build.

---

# 1. CORE SYSTEMS
- YesQuid Sovereign OS
- Full Stack Builder
- Planetary Agents Hub
- TotalRecall Engine
- Ultimate HTML Hunter
- YesQuid Cyberdeck UI

---

# 2. REPODEPO / EVIDENCE ENGINE
## Repository Root
- deploy.sh
- MANIFEST.json
- README.md
- repo_structure.txt

## Evidence Modules
- VideoCourts/
- AiRecords/
- AiMetaverse/
- Agents/
- TotalRecall/
- FacePrintPay/
- SlamAR/
- MyBuyO/

## Auth & Publishing
- github_wedding.sh
- repodepo_v2_faceprintpay.sh

---

# 3. PLANETARY AGENTS (25)
- Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, Titan,
  Eris, Chronos, ALFAI, Callisto, Moon, ExplorerMars, SlamAR, MyBuyO, TailView,
  Send2Repo, TrickorTrakR, Ceres, CoManD, EmpireCoord, Sun

---

# 4. FULL STACK PACKAGING SYSTEM
- YesQuid_FullStack_Build/
- yesquid-fullstack-v1.0.0-*.tar.gz
- RELEASE_MANIFEST.json
- VERSION

---

# 5. TOTALRECALL MEMORY ENGINE
- Evidence bundles
- State management
- Timeline reconstruction
- Audio processors
- Incident logs
- Z-file assembly

---

# 6. VIDEOCOURTS JUSTICE STACK
- Blockchain-integrated case file generation
- Public case management
- Deployment scripts
- Court evidence exporters

---

# 7. UI / FRONTEND SYSTEMS
- YesQuid Control Center HTML interface
- HTML Hunter INDEX.html
- Web dashboards for RepoDepo, Agents, TotalRecall

---

# 8. SECURITY & INFRASTRUCTURE
- OpenTimestamps anchoring
- Bitcoin timestamping
- SHA256 hashing
- FacePrintPay biometric auth
- Secure GitHub push pipeline
- Merkle proof verification layer

---

# 9. AUTONOMOUS PIPELINE SYSTEM
- Multi-agent orchestration
- Swarm deployment workflows
- Full-stack build automation
- Evidence packaging chain
- Biometric → Repo push chain

---

# END OF MANIFEST
EOF

echo -e "${GREEN}✓ PACKAGES_MANIFEST.md created${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Extra: Task list for this build
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 6C]${NC} Creating task list for this build..."

cat > TASKS_SOVEREIGN_BUILD.md <<'EOF'
# Sovereign Architect – Build Task List

## Phase 0: Environment
- [ ] Update Termux packages
- [ ] Install git, gh, python, jq
- [ ] Install Python libs: openai, rich

## Phase 1: Repo Setup
- [ ] Create local folder `sovereign-architect`
- [ ] Initialize git, set `main` branch
- [ ] Authenticate GitHub via `gh auth login`
- [ ] Create private repo `sovereign-architect`
- [ ] Link `origin` remote

## Phase 2: Core Directories
- [ ] Create `agents/`, `plans/`, `profiles/`, `storage/`
- [ ] Create `docs/`, `scripts/`, `configs/`, `manifests/`

## Phase 3: Agent Stack
- [ ] Add `agents/agent_architect.sh`
- [ ] Add `agents/architect_planner.py`
- [ ] Add `agents/architect_enqueue.py`
- [ ] Make all `.sh` and `.py` executable

## Phase 4: Identity & Metadata
- [ ] Create `profiles/sovereign_architect_profile.json`
- [ ] Create `PACKAGES_MANIFEST.md`
- [ ] Create `TASKS_SOVEREIGN_BUILD.md`

## Phase 5: First Plan
- [ ] Run first goal through architect agent
- [ ] Verify JSON plan created under `~/plans/`
- [ ] Pretty-print newest plan via `jq`

## Phase 6: Commit & Push
- [ ] Stage all files with `git add .`
- [ ] Commit with message "Full sovereign architect stack + first Series A plan"
- [ ] Push to `origin main`
- [ ] Verify repo on GitHub via `gh repo view --web`

## Phase 7: Next Integrations (External)
- [ ] Link or document paths to:
      - `~/Kre8tiveKonceptz_RepoDepo`
      - `~/YesQuid`
      - `~/TotalRecall`
      - `~/videocourts-justice-stack`
- [ ] Add docs describing how Sovereign Architect plans orchestrate these stacks
EOF

echo -e "${GREEN}✓ TASKS_SOVEREIGN_BUILD.md created${NC}"
echo ""

#────────────────────────────────────────────────────────────
# Step 7: Generate first real plan
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 7]${NC} Generating first SovereignGTP Series A plan..."

cd "$REPO_DIR"
./agents/agent_architect.sh "Build a 10-slide Banani-ready Series A deck for SovereignGTP with valuation, ROI, compliance, and outreach sections."

echo ""

#────────────────────────────────────────────────────────────
# Step 8: Show it nicely
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 8]${NC} Listing plans and pretty-printing latest..."

echo -e "\nAll plans:"
ls -lt ~/plans/plan_*.json

LATEST=$(ls -t ~/plans/plan_*.json | head -n1)
echo -e "\nLatest plan: $LATEST\n"

jq '{plan_id, goal, status, step_count: (.steps | length), created_at}' "$LATEST"

echo -e "\nFull numbered steps:\n"
jq -r '.steps[] | "\(.step_id). \(.title)\n   → \(.objective)\n   Status: \(.status)\n"' "$LATEST"

#────────────────────────────────────────────────────────────
# Step 9: Commit & push
#────────────────────────────────────────────────────────────
echo -e "${BLUE}[STEP 9]${NC} Committing and pushing to GitHub..."

cd "$REPO_DIR"
git add .
git commit -m "Full sovereign architect stack + first Series A plan" || echo -e "${YELLOW}Nothing new to commit (maybe rerun).${NC}"
git push -u origin main

echo -e "\n${GREEN}✓ Code pushed to GitHub${NC}"
echo -e "\nLive private repo (opens in browser if supported):"
gh repo view --web

echo -e "\n${CYAN}All done. Sovereign Architect stack is live.${NC}"
