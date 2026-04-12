#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/constellation25}"
LOGS_DIR="${LOGS_DIR:-$BASE_DIR/logs}"
TOTALRECALL_DIR="${TOTALRECALL_DIR:-$HOME/TotalRecall/constellation25}"
AGENTS_DIR="${AGENTS_DIR:-$BASE_DIR/agents}"
OUTPUT_DIR="${OUTPUT_DIR:-$BASE_DIR/build-output}"
TASKS_DIR="${TASKS_DIR:-$BASE_DIR/tasks}"
INPUT_DIR="${INPUT_DIR:-$BASE_DIR/json-input}"
VAULT_DIR="${VAULT_DIR:-$BASE_DIR/vault}"
TIMESTAMP="$(date -u)"

mkdir -p "$LOGS_DIR" "$TOTALRECALL_DIR"

check_deps() {
  for p in jq findutils git curl; do
    pkg list-installed 2>/dev/null | grep -q "^$p " || pkg install -y "$p" >> "$LOGS_DIR/deps.log" 2>&1
  done
}
check_deps

run_status() {
  printf "[STATUS] Constellation25\n"
  printf "  Agents: %s\n" "$(ls -1 $AGENTS_DIR/*.sh 2>/dev/null | wc -l)"
  printf "  TotalRecall: %s\n" "$(wc -l < $TOTALRECALL_DIR/blockchain_manifest.txt 2>/dev/null || echo 0)"
  printf "[OK] System Operational\n"
}

run_json() {
  local input="${1:-}"
  [ -z "$input" ] && input=$(ls -t "$INPUT_DIR"/*.json 2>/dev/null | head -1)
  [ -z "$input" ] && { printf "[ERROR] No input\n"; exit 1; }
  local job_id="job_$(date +%s)_$$"
  printf "[INFO] Job: %s\n" "$job_id"
  for agent in earth mars cygnus; do
    local script="$AGENTS_DIR/${agent}-agent.sh"
    [ -x "$script" ] && bash "$script" "build" "$job_id" "$input" >> "$LOGS_DIR/${agent}.log" 2>&1
  done
  printf "[OK] Build Complete\n"
}

main() {
  local mode="${1:-status}"
  case "$mode" in
    status) run_status ;;
    json) run_json "${2:-}" ;;
    *) printf "Usage: %%s [status|json]\n" "$0" ;;
  esac
}
main "$@"
