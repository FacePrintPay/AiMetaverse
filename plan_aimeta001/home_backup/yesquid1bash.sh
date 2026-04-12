#!/bin/bash
# YESQUID / NLP2CODE / PUSH2REPO - OMNIBUS 1-BASH
# Central command for:
#   - VideoCourts Justice Stack
#   - TotalRecall Engine
#   - Planetary Agents registry
#   - Push2Repo helper
#
# Usage:
#   yesquid1bash.sh status|init|build|run|agents|agent|nlp|sync

set -euo pipefail

#=============================
# CONFIG
#=============================
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"

YESQUID_HOME="$HOME_DIR/YesQuid"
STACK_HOME="$HOME_DIR/videocourts-justice-stack"
TOTALRECALL_BIN="$HOME_DIR/TotalRecall/totalrecall_engine.sh"
LOG_DIR="$YESQUID_HOME/logs"
STATE_FILE="$YESQUID_HOME/state.json"

# Optional helpers
SERVE_WEB_SCRIPT="$HOME_DIR/serve_videocourts_web.sh"
BOOTSTRAP_SCRIPT="$HOME_DIR/videocourts_justice_stack_bootstrap.sh"

mkdir -p "$YESQUID_HOME" "$LOG_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

#=============================
# BANNER
#=============================
banner() {
  cat << 'EOF'
╔══════════════════════════════════════════════╗
║     YESQUID / PaTHos  •  1-BASH OMNIBUS     ║
║  NLP2CODE · Push2Repo · TotalRecall · VC    ║
╚══════════════════════════════════════════════╝
EOF
}

#=============================
# JSON HELPER
#=============================
json_escape() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_out() {
  local ok="$1"; shift
  local cause="$1"; shift
  local hint="${1:-}"; shift || true

  local trace
  trace="$(tr -dc 'a-f0-9' </dev/urandom 2>/dev/null | head -c16 || echo "trace-$(date +%s)")"

  printf '{'
  printf '"ok":%s,' "$ok"
  printf '"cause":"%s",' "$(echo "$cause" | json_escape)"
  printf '"hint":"%s",' "$(echo "$hint" | json_escape)"
  printf '"trace":"%s"' "$trace"
  printf '}\n'
}

#=============================
# STATUS
#=============================
cmd_status() {
  banner
  echo -e "${CYAN}STATUS:${NC}"

  local vc="false" tr="false" git="false"

  [ -d "$STACK_HOME" ] && vc="true"
  [ -x "$TOTALRECALL_BIN" ] && tr="true"
  [ -d "$STACK_HOME/.git" ] && git="true"

  json_out "true" "ok" "yesquid stack status" | sed 's/}$/,/'
  printf '"paths":{'
  printf '"YESQUID_HOME":"%s",' "$(echo "$YESQUID_HOME" | json_escape)"
  printf '"STACK_HOME":"%s",' "$(echo "$STACK_HOME" | json_escape)"
  printf '"TOTALRECALL_BIN":"%s"' "$(echo "$TOTALRECALL_BIN" | json_escape)"
  printf '},'
  printf '"flags":{'
  printf '"videocourts_monorepo":%s,' "$vc"
  printf '"totalrecall_present":%s,' "$tr"
  printf '"git_repo":%s' "$git"
  printf '}}\n'
}

#=============================
# INIT
#=============================
cmd_init() {
  banner
  echo -e "${BLUE}[*] INITIALIZING YESQUID STACK${NC}"

  mkdir -p "$YESQUID_HOME" "$LOG_DIR"

  cat >"$STATE_FILE" <<EOF
{
  "version": "1.0",
  "created_at": "$(date -Iseconds 2>/dev/null || date)",
  "stack_home": "$STACK_HOME",
  "totalrecall": "$TOTALRECALL_BIN",
  "notes": "YesQuid omniplex init complete."
}
EOF

  echo -e "${GREEN}[✓]${NC} State file: $STATE_FILE"

  if [ -x "$BOOTSTRAP_SCRIPT" ]; then
    echo -e "${BLUE}[*]${NC} Detected bootstrap script (not auto-running)."
    echo "    $BOOTSTRAP_SCRIPT"
  else
    echo -e "${YELLOW}[!] No bootstrap script found at:${NC}"
    echo "    $BOOTSTRAP_SCRIPT"
  fi

  json_out "true" "initialized" "yesquid init"
}

#=============================
# BUILD
#=============================
cmd_build() {
  banner
  echo -e "${BLUE}[*] BUILD: Justice stack + docs + web${NC}"

  if [ -x "$BOOTSTRAP_SCRIPT" ]; then
    echo -e "${BLUE}→ Running bootstrap:${NC} $BOOTSTRAP_SCRIPT"
    "$BOOTSTRAP_SCRIPT"
  else
    echo -e "${YELLOW}[!] No bootstrap script, assuming monorepo is already present.${NC}"
  fi

  if [ -d "$STACK_HOME" ]; then
    echo -e "${GREEN}[✓]${NC} Monorepo present: $STACK_HOME"
  else
    echo -e "${RED}[✗]${NC} Monorepo not found at $STACK_HOME"
  fi

  json_out "true" "build-complete" "yesquid build"
}

#=============================
# RUN
#=============================
cmd_run() {
  banner
  echo -e "${BLUE}[*] RUN: serve VideoCourts web + ping TotalRecall${NC}"

  if [ -x "$TOTALRECALL_BIN" ]; then
    "$TOTALRECALL_BIN" --ping "yesquid-run-$(date +%s)" || true
  else
    echo -e "${YELLOW}[!] TotalRecall not found at ${TOTALRECALL_BIN}${NC}"
  fi

  if [ -x "$SERVE_WEB_SCRIPT" ]; then
    "$SERVE_WEB_SCRIPT"
  else
    local web_root="$STACK_HOME/apps/videocourts-web"
    if [ -d "$web_root" ]; then
      cd "$web_root"
      python3 -m http.server 8085
    else
      echo -e "${RED}[✗]${NC} Missing web root: $web_root"
    fi
  fi
}

#=============================
# AGENTS LIST
#=============================
cmd_agents() {
  banner
  cat << 'EOF'
Planetary Agents Registry:
  Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto,
  Sun, Moon, Titan, Eris, Chronos, Ceres, Callisto, ALFAI, ExplorerMars,
  CoMan’d, SlamAR, Send2Repo, TrickorTrakR, TailView, MyBuyO, EmpireCoord.
EOF
}

#=============================
# AGENT DIRECT
#=============================
cmd_agent_direct() {
  local agent="${1:-}"
  banner
  cat <<EOF
{"ok":true,"agent":"$agent","mode":"stub","hint":"Wire this to a real orchestrator"}
EOF
}

#=============================
# NLP2CODE (stub)
#=============================
cmd_nlp() {
  banner
  cat << 'EOF'
YesQuid NLP2CODE Entry:
  This will:
    - Parse prompt
    - Route to Mercury (router) + Mars (compiler)
    - Generate code into monorepo
    - Trigger Send2Repo automatically

(Currently a stub)
EOF
}

#=============================
# PUSH2REPO
#=============================
send2repo() {
  local msg="${1:-"yesquid: sync"}"
  banner
  if [ ! -d "$STACK_HOME/.git" ]; then
    json_out "false" "no-git" "init git manually"
    return 0
  fi

  cd "$STACK_HOME"

  git add -A
  git commit -m "$msg" || true

  if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    git push
  fi

  json_out "true" "sync-complete" "$msg"
}

#=============================
# MAIN
#=============================
main() {
  local cmd="${1:-status}"

  case "$cmd" in
    status)  cmd_status ;;
    init)    shift; cmd_init "$@" ;;
    build)   shift; cmd_build "$@" ;;
    run)     shift; cmd_run "$@" ;;
    agents)  cmd_agents ;;
    agent)   shift; cmd_agent_direct "$@" ;;
    nlp)     shift || true; cmd_nlp "$@" ;;
    sync)    shift || true; send2repo "yesquid: manual sync" ;;
    *)
      echo "Usage: $(basename "$0") {status|init|build|run|agents|agent|nlp|sync}" >&2
      exit 1
      ;;
  esac
}

main "$@"
