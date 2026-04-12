#!/data/data/com.termux/files/usr/bin/bash
# Sovereign GTP Protocol

export SOVEREIGN_GTP_PROTOCOL="ACTIVE"
export SOVEREIGN_HOME="$HOME/SOVEREIGN_GTP"
export PATH="$PATH:$SOVEREIGN_HOME/core"

# Color codes
CYBER_CYAN='\033[96m'
CYBER_GREEN='\033[92m'
RESET='\033[0m'

echo -e "${CYBER_CYAN}[SovereignGTP] Protocol online.${RESET}"
echo -e "${CYBER_GREEN}Home: $SOVEREIGN_HOME${RESET}"

# Aliases
alias sov='cd $SOVEREIGN_HOME'
alias sovcore='cd $SOVEREIGN_HOME/core'
alias sovagents='cd $SOVEREIGN_HOME/agents'
alias sovlogs='cd $SOVEREIGN_HOME/logs'
alias sovvault='cd $SOVEREIGN_HOME/vault'
alias sovweb='cd $SOVEREIGN_HOME/web'
