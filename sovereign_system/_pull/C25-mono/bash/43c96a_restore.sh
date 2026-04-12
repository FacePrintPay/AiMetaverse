#!/data/data/com.termux/files/usr/bin/bash
# Sovereign GTP - System Restoration

SOV_HOME="$HOME/SOVEREIGN_GTP"
CORE="$SOV_HOME/core"
AGENTS="$SOV_HOME/agents"
LOGS="$SOV_HOME/logs"
VAULT="$SOV_HOME/vault"
WEB="$SOV_HOME/web"
DOCS="$SOV_HOME/docs"
MEM="$SOV_HOME/memories"

# Ensure structure exists
for dir in "$CORE" \
           "$AGENTS/planetary" \
           "$AGENTS/shadow" \
           "$AGENTS/chaos" \
           "$LOGS" \
           "$VAULT" \
           "$WEB" \
           "$DOCS" \
           "$MEM"; do
    [ -d "$dir" ] || mkdir -p "$dir"
done

# Rebuild protocol if missing
if [ ! -f "$CORE/protocol.sh" ]; then
    echo "[!] Protocol missing - run emergency recovery"
    return 1
fi

# Apply protocol
source "$CORE/protocol.sh"

# Verify components
echo "[✓] Directories verified"
echo "[✓] Protocol active"
echo "[✓] Sovereign home: $SOV_HOME"
