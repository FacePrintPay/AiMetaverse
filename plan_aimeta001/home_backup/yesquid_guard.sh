#!/data/data/com.termux/files/usr/bin/bash
# YesQuid / Sovereign Guard
# Centralized checks so we stop getting "wtf" errors.

set -u  # don't use -e here; we want controlled exits, not silent death

log_info() { printf '[GUARD][INFO] %s\n' "$*"; }
log_warn() { printf '[GUARD][WARN] %s\n' "$*"; }
log_err()  { printf '[GUARD][ERROR] %s\n' "$*" >&2; }

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_err "Command not found: $cmd"
    log_err "Install it or fix PATH. Current PATH: $PATH"
    exit 127
  fi
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    log_err "Expected file missing: $path"
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    log_err "Expected directory missing: $path"
    exit 1
  fi
}

# Soft check: warn but don't exit
warn_if_missing() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    log_warn "Optional path missing (ok): $path"
  fi
}

yesquid_core_check() {
  log_info "Running YesQuid core env check…"

  # Base dirs
  require_dir "$HOME"
  require_dir "$HOME/SOVEREIGN_MASTER"

  # Optional but important scripts
  warn_if_missing "$HOME/yesquid_master_index.sh"
  warn_if_missing "$HOME/yesquid_master_materialize.sh"

  warn_if_missing "$HOME/yesquid_bootstrap.sh"
  warn_if_missing "$HOME/yesquid_pathos_kernel_bootstrap.sh"
  warn_if_missing "$HOME/yesquid_shell_guard.sh"
  warn_if_missing "$HOME/yesquid_immutable_core.sh"

  # YesQuid / sgtp CLI
  require_cmd sgtp

  log_info "YesQuid core env looks sane."
}
