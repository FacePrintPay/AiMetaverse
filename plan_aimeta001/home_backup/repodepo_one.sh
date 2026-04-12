#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="$HOME"
REPO="$HOME_DIR/Kre8tiveKonceptz_RepoDepo"
VAULT="$HOME_DIR/SOVEREIGN_VAULT/Z-36/ai-kre8tive-stargate"

ARTIFACTS="$REPO/artifacts"
SCRIPTS="$REPO/scripts"
LOGS="$REPO/logs"
STATE="$REPO/.state"

APP="$VAULT/builds/code_gen/output.py"
PID_FILE="$STATE/key_rotation_api.pid"
LOG_FILE="$LOGS/uvicorn_key_rotation.log"

HOST="127.0.0.1"
PORT="8000"
URL="http://$HOST:$PORT"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
say(){ echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $*"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $*"; }
die(){ echo -e "${RED}[ERR]${NC} $*"; exit 1; }

need(){ command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }

need bash; need python; need curl; need jq; need nohup

mkdir -p \
  "$ARTIFACTS"/{01_yesquid_pathos,02_state_management,03_cloud_integration,04_videocourts,05_tools_utilities,06_documentation} \
  "$SCRIPTS" "$LOGS" "$STATE"

[ -f "$APP" ] || die "API app not found: $APP"

start(){
  if status >/dev/null; then warn "API already running"; return 0; fi
  say "Starting API…"
  nohup python "$APP" >"$LOG_FILE" 2>&1 &
  echo $! >"$PID_FILE"
  sleep 1
  status
}

stop(){
  if [ ! -f "$PID_FILE" ]; then warn "API not running"; return 0; fi
  say "Stopping API…"
  kill "$(cat "$PID_FILE")" 2>/dev/null || true
  rm -f "$PID_FILE"
}

status(){
  if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" >/dev/null 2>&1; then
    say "API RUNNING (PID $(cat "$PID_FILE")) → $URL"
    return 0
  fi
  warn "API STOPPED"
  return 1
}

smoke(){
  say "Smoke test…"
  curl -s "$URL/" | jq .
  curl -s -X POST "$URL/rotate-key" \
    -H "content-type: application/json" \
    -d '{"service_name":"RepoDepo","key_type":"api_key"}' | jq .
  say "Smoke test OK"
}

logs(){ tail -n 120 "$LOG_FILE"; }

case "${1:-help}" in
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  smoke) smoke ;;
  logs) logs ;;
  *)
    cat <<EOF
Usage: $(basename "$0") {start|stop|restart|status|smoke|logs}

Repo   : $REPO
Vault  : $VAULT
App    : $APP
Logs   : $LOG_FILE
EOF
    ;;
esac
