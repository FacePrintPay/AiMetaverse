#!/data/data/com.termux/files/usr/bin/bash
# The beating heart of the sovereign system

export PATH="$PATH:$HOME/SOVEREIGN_GTP"
export SOVEREIGN_HOME="$HOME/SOVEREIGN_GTP"
export AGENT_PATH="$SOVEREIGN_HOME/agents"
export VAULT_PATH="$SOVEREIGN_HOME/vault"
export MEMORY_PATH="$SOVEREIGN_HOME/memories"
export LOG_PATH="$SOVEREIGN_HOME/logs"

# Aesthetic configs
export NEON_PINK='\033[95m'
export CYBER_CYAN='\033[96m'
export MATRIX_GREEN='\033[92m'
export PLASMA_YELLOW='\033[93m'
export VOID_PURPLE='\033[35m'
export BLOOD_RED='\033[91m'
export GHOST_WHITE='\033[97m'
export RESET='\033[0m'

# Agent configs
export INFINITE_MODE=true
export CYCLE_INTERVAL=900  # 15 minutes
export CHAOS_FACTOR=0.1    # 10% randomness injection
