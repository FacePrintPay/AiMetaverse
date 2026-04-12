#!/bin/bash
set -euo pipefail
AGENTIK_HOME="${HOME}/Agentik"
LOG_DIR="${AGENTIK_HOME}/logs"
mkdir -p "${LOG_DIR}"

start() {
  local mod="$1"; shift
  if tmux has-session -t "${mod}" 2>/dev/null; then
    echo "⚠️  ${mod} already running" >&2
    return 1
  fi
  echo "🚀 Launching ${mod}"
  tmux new-session -d -s "${mod}" \
    "exec bash -c 'cd ${AGENTIK_HOME}/${mod} && ./run.sh \"$@\" 2>&1 | tee -a ${LOG_DIR}/${mod}.log'"
}

stop() { tmux kill-session -t "$1" 2>/dev/null && echo "🛑 Stopped $1" || echo "❌ $1 not running"; }
logs() { tail -f "${LOG_DIR}/$1.log" 2>/dev/null || echo "No logs for $1"; }

case "${1:-}" in
  start)  start "${2:-}" "${@:3}" ;;
  stop)   stop "${2:-}" ;;
  logs)   logs "${2:-}" ;;
  *)      echo "Usage: $0 [start|stop|logs] <Agentik-Module>"; exit 1 ;;
esac
