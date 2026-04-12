#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
LOG="$HOME/.constellation25/swarm.log"
mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date "+%H:%M:%S")] $1" | tee -a "$LOG"; }
log "🌌 Constellation 25: Inngest Integration Started"
export INNGEST_EVENT_KEY="${INNGEST_EVENT_KEY}"}"
export INNGEST_SIGNING_KEY="${INNGEST_SIGNING_KEY}"}"
log "✅ Keys configured"
export INNGEST_DEV=1
export INNGEST_BASE_URL="http://localhost:8288"
log "🔗 Environment ready for self-hosted Inngest"
echo "✅ Integration complete. Next: cd ~/constellation25/inngest-project && ./start.sh"
