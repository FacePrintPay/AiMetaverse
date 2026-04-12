#!/data/data/com.termux/files/usr/bin/bash
run() {
  set -euo pipefail
  local AGENT="${RUN_AGENT:-mercury}"
  case "${1:-}" in
    mercury|earth|mars|venus|totalrecall) AGENT="$1"; shift ;;
  esac
  local FIND_PATH="${1:-~}"; shift || true
  echo "[RUN] Agent: $AGENT | Path: $FIND_PATH | Args: $*"
  find "$FIND_PATH" "$@"
}
run-count() { run "$@" ~ -type f 2>/dev/null | wc -l; }
run-sh() { run "$@" ~ -name "*.sh" -type f; }
run-md() { run "$@" ~ -name "*.md" -type f; }
run-large() { run "$@" ~ -type f -size +5M -exec ls -lh {} \;; }
export -f run run-count run-sh run-md run-large
