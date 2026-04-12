#!/bin/bash
set -euo pipefail
AGENTIK_HOME="${HOME}/Agentik"
LOG_DIR="${AGENTIK_HOME}/logs"
mkdir -p "${LOG_DIR}"

SEED_TASKS=(
  "AiMetaverse,Agentik-Deploy,vercel"
  "SovereignGTP,Agentik-Deploy,apk"
  "VideoCourts,Agentik-Deploy,godaddy"
  "Agentik,Agentik-Outreach,cashapp"
  "AiMetaverse,Agentik-Scout,suppression"
)

log() { echo "[$(date -Iseconds)] [BASH-THE-AGE] $*" | tee -a "${LOG_DIR}/bash-the-age.log"; }

log "🚀 BASHING THE AGE — launching ${#SEED_TASKS[@]} tasks"
for TASK in "${SEED_TASKS[@]}"; do
  IFS=',' read -r REPO MODULE TARGET <<< "$TASK"
  log "→ Dispatching: ${MODULE} | ${REPO} | ${TARGET}"
  "${AGENTIK_HOME}/agentctl.sh" start "${MODULE}" "${REPO}" "${TARGET}" &
  sleep 1
done
wait
log "✅ ALL TASKS DISPATCHED"
