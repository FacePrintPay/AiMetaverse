#!/bin/bash
# YESQUID INVESTOR SWARM ORCHESTRATOR
# Wires planetary agents into an "investor search + outreach" stack.

set -euo pipefail

YESQUID_HOME="$HOME/YesQuid"
AGENTS_ROOT="$YESQUID_HOME/agents"
LOG_ROOT="$YESQUID_HOME/agents-logs"
INVEST_ROOT="$YESQUID_HOME/investor_swarm"
MANIFEST="$INVEST_ROOT/swarm_manifest.json"
TARGETS_FILE="$INVEST_ROOT/investor_targets_seed.json"
PIPELINE_MD="$INVEST_ROOT/outreach_pipeline.md"
REPORT_MD="$INVEST_ROOT/investor_briefing.md"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

heading() {
  echo -e ""
  echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  $1${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
}

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_err() {
  echo -e "${RED}[ERR ]${NC} $1" >&2
}

ensure_dirs() {
  mkdir -p "$INVEST_ROOT"
  mkdir -p "$LOG_ROOT"
}

init_manifest() {
  heading "INITIALIZING INVESTOR SWARM MANIFEST"
  ensure_dirs

  cat > "$MANIFEST" <<EOF
{
  "created_at": "$(date --iso-8601=seconds)",
  "stack": "yesquid-investor-swarm",
  "agents": {
    "alfai": {
      "role": "Outreach & partnerships",
      "duties": [
        "Identify aligned investors, angels, and funds",
        "Draft personalized outreach hooks",
        "Map investor theses to Kre8tive Konceptz products"
      ]
    },
    "ceres": {
      "role": "Monetization node",
      "duties": [
        "Model deal structures and revenue scenarios",
        "Prioritize investors by potential value",
        "Translate tech into business language"
      ]
    },
    "explorermars": {
      "role": "Discovery / repo & API scanner",
      "duties": [
        "Scan ecosystems: accelerators, grant programs, AI funds",
        "Pull structured lists from curated sources (manual/APIs later)",
        "Tag leads by stage, geo, and thesis"
      ]
    },
    "empirecoord": {
      "role": "Overseer / self-healing",
      "duties": [
        "Coordinate investor-scouting runs",
        "Check swarm health and missing data",
        "Produce executive-level summary"
      ]
    },
    "tailview": {
      "role": "UI preview renderer",
      "duties": [
        "Prepare presentable output snapshots",
        "Format briefings for investors/partners",
        "Surface top 10 'right-now' targets"
      ]
    },
    "mars": {
      "role": "Compiler / NLP2CODE",
      "duties": [
        "Turn narrative into structured artifacts",
        "Generate CSV/JSON lists of investors",
        "Prepare submission-ready data for decks, sites, and emails"
      ]
    }
  }
}
EOF

  log_info "Swarm manifest written to: $MANIFEST"
}

init_targets_seed() {
  heading "SEEDING INVESTOR TARGETS CONFIG"

  cat > "$TARGETS_FILE" <<EOF
{
  "version": 1,
  "thesis": "Investors aligned with AI infrastructure, justice tech, payments, and sovereign data / AI.",
  "filters": {
    "min_check_size_usd": 25000,
    "stages": ["pre-seed", "seed", "early revenue"],
    "geo_preference": ["US-wide", "remote-friendly"],
    "themes": [
      "AI infra / dev tools",
      "legal tech / justice access",
      "fintech / biometric payments",
      "creator economy / AI music"
    ]
  },
  "priority_verticals": [
    "Justice / Courts (VideoCourts)",
    "AI Infrastructure (PaTHos / YesQuid)",
    "Payments (FacePrintPay / MyBuyO)",
    "Creator Tools (AiRecords / AiMetaverse)"
  ],
  "manual_seeds": [
    {
      "label": "YC-style accelerators",
      "status": "todo",
      "notes": "Shortlist programs with AI infra / gov / justice focus."
    },
    {
      "label": "Vertical justice tech VCs",
      "status": "todo",
      "notes": "Funds that have invested in court tech, e-filing, or public safety platforms."
    },
    {
      "label": "Fintech / payments angels",
      "status": "todo",
      "notes": "Founders / angels who exited paytech / POS / biometric plays."
    }
  ]
}
EOF

  log_info "Investor targets seed config written to: $TARGETS_FILE"
}

init_pipeline_doc() {
  heading "WRITING OUTREACH PIPELINE DOC"

  cat > "$PIPELINE_MD" <<EOF
# YesQuid Investor Swarm – Outreach Pipeline

This document defines how planetary agents collaborate to find and prioritize investors.

## 1. Agent Roles

- **ALFAI (Outreach & Partnerships)**
  - Translates product language into investor-resonant hooks
  - Generates outreach angles and short intros
  - Maintains a list of "warm intro" targets vs "cold outbound"

- **CERES (Monetization Node)**
  - Turns features into business cases
  - Estimates revenue, ACV, TAM/SAM language
  - Prioritizes leads by economic upside

- **ExplorerMars (Discovery / Scanner)**
  - Sweeps the ecosystem: accelerators, VCs, angels, grants
  - Tags each lead with: stage, thesis, geo, ticket size
  - Writes raw CSV/JSON into investor_swarm/data/

- **EmpireCoordinator (Overseer)**
  - Orchestrates "runs" of the swarm
  - Kicks off scans, compiles status, raises red flags
  - Writes summary logs for humans to act on

- **TailView (UI Preview Renderer)**
  - Prepares "Top 10" cards or views for each run
  - Outputs Markdown, HTML, or JSON snapshots

- **Mars (Compiler / NLP2CODE)**
  - Generates machine-usable artifacts:
    - investor_targets.csv
    - investor_notes.md
    - api_payloads.json (for future API-based outreach)

## 2. Standard Run Types

### Run Type: "scout"

Goal: Expand the investor universe and tag potential matches.

- ExplorerMars:
  - Task: "scan ecosystem for aligned funds and programs"
  - Output: raw list(s) under investor_swarm/data/

- ALFAI:
  - Task: "draft positioning + angles for this run"
  - Output: hooks and one-liners for each vertical

- Ceres:
  - Task: "estimate deal size and map to verticals"
  - Output: ranked list by deal potential

### Run Type: "brief"

Goal: Prepare a human-readable investor briefing.

- Mars:
  - Task: "compile latest data into investor_briefing.md"
- TailView:
  - Task: "render quick-glance summary / cards"
- EmpireCoordinator:
  - Task: "final check and sign-off"

## 3. Human-In-The-Loop Points

- You approve:
  - Top 10 priority investors / programs per cycle
  - Final language for intros and pitches
  - Any sharing of sovereign artifacts / evidence bundles

EOF

  log_info "Outreach pipeline doc written to: $PIPELINE_MD"
}

init_report_stub() {
  heading "INIT INVESTOR BRIEFING STUB"

  cat > "$REPORT_MD" <<EOF
# Investor Briefing – Scaffold

_Last generated: $(date --iso-8601=seconds)_

## 1. Snapshot

- Status: Scaffold only (no external queries yet)
- Swarm agents wired:
  - ALFAI, CERES, ExplorerMars, Mars, TailView, EmpireCoordinator

## 2. Core Story

You are funding a *sovereign AI justice and infrastructure stack*:
- VideoCourts (remote justice + evidence engine)
- PaTHos / YesQuid (NLP2CODE & command deck)
- TotalRecall (forensic memory + evidence)
- FacePrintPay / MyBuyO (biometric payments)
- AiRecords / AiMetaverse (creator stack)

## 3. Next Step

Once external data sources are wired (APIs, curated lists),
this doc will automatically compile a "Top 10" per run, with:

- Name, fund, stage, geo
- Why they align with this stack
- Recommended introduction angle
EOF

  log_info "Investor briefing stub written to: $REPORT_MD"
}

run_scout() {
  heading "RUN TYPE: SCOUT (DISCOVERY + POSITIONING)"

  ensure_dirs

  log_info "Dispatching ExplorerMars (discovery)..."
  if [ -x "$AGENTS_ROOT/explorermars/run.sh" ]; then
    "$AGENTS_ROOT/explorermars/run.sh" "investor-scout: discover accelerators, funds, angels, grants aligned with justice-tech + AI infra"
  else
    log_warn "explorermars/run.sh missing or not executable"
  fi

  log_info "Dispatching ALFAI (outreach & partnerships)..."
  if [ -x "$AGENTS_ROOT/alfai/run.sh" ]; then
    "$AGENTS_ROOT/alfai/run.sh" "investor-scout: generate outreach angles and 1-liner hooks per vertical"
  else
    log_warn "alfai/run.sh missing or not executable"
  fi

  log_info "Dispatching Ceres (monetization node)..."
  if [ -x "$AGENTS_ROOT/ceres/run.sh" ]; then
    "$AGENTS_ROOT/ceres/run.sh" "investor-scout: rank investors by potential revenue impact and strategic fit"
  else
    log_warn "ceres/run.sh missing or not executable"
  fi

  log_info "Dispatching EmpireCoordinator (overseer)..."
  if [ -x "$AGENTS_ROOT/empirecoord/run.sh" ]; then
    "$AGENTS_ROOT/empirecoord/run.sh" "investor-scout: swarm health + initial target ranking"
  else
    log_warn "empirecoord/run.sh missing or not executable"
  fi

  log_info "Scout run triggered. Check logs under: $LOG_ROOT"
}

run_brief() {
  heading "RUN TYPE: BRIEF (GENERATE INVESTOR BRIEFING)"

  ensure_dirs

  log_info "Dispatching Mars (compiler)..."
  if [ -x "$AGENTS_ROOT/mars/run.sh" ]; then
    "$AGENTS_ROOT/mars/run.sh" "investor-brief: compile investor_swarm data into investor_briefing"
  else
    log_warn "mars/run.sh missing or not executable"
  fi

  log_info "Dispatching TailView (UI renderer)..."
  if [ -x "$AGENTS_ROOT/tailview/run.sh" ]; then
    "$AGENTS_ROOT/tailview/run.sh" "investor-brief: prepare visual snapshot of priority targets"
  else
    log_warn "tailview/run.sh missing or not executable"
  fi

  log_info "Dispatching EmpireCoordinator (overseer)..."
  if [ -x "$AGENTS_ROOT/empirecoord/run.sh" ]; then
    "$AGENTS_ROOT/empirecoord/run.sh" "investor-brief: verify outputs and mark ready-for-human-review"
  else
    log_warn "empirecoord/run.sh missing or not executable"
  fi

  log_info "Brief run triggered. Check $REPORT_MD and $LOG_ROOT"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  init      - set up investor_swarm manifest, config, and docs
  scout     - run discovery-oriented investor scouting pass
  brief     - compile current info into a briefing skeleton
EOF
}

main() {
  cmd="${1:-}"

  case "$cmd" in
    init)
      init_manifest
      init_targets_seed
      init_pipeline_doc
      init_report_stub
      ;;
    scout)
      run_scout
      ;;
    brief)
      run_brief
      ;;
    ""|-h|--help)
      usage
      ;;
    *)
      log_err "Unknown command: $cmd"
      usage
      exit 1
      ;;
  esac
}

main "$@"
