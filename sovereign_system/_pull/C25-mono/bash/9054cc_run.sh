#!/bin/bash
set -euo pipefail

ACTION="$1"
LICENSE_ID="$2"
PRODUCT="$3"

LOG="${HOME}/Agentik/logs/Agentik-Deploy.log"
log() { echo "[$(date)] [Deploy] $*" >> "${LOG}"; }

case "${ACTION}" in
  Fulfill)
    log "🔓 Fulfilling ${PRODUCT} license: ${LICENSE_ID}"
    
    case "${PRODUCT}" in
      Agentik-Presale|Agentik-Micro)
        echo "${LICENSE_ID},agentik,active,$(date)" >> ~/Agentik/fulfilled_licenses.csv
        ;;
      Parasol)
        echo "${LICENSE_ID},parasol,active,$(date)" >> ~/Agentik/parasol_clients.csv
        ~/Agentik/Agentik-Scout/run.sh "watch" "${LICENSE_ID}" &
        ;;
    esac
    
    log "✅ ${PRODUCT} fulfilled for ${LICENSE_ID}"
    ;;
  *)
    log "Running mock task: $*"
    ;;
esac
