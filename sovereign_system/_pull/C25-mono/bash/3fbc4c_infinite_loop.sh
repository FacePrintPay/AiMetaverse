#!/data/data/com.termux/files/usr/bin/bash
source "$HOME/SOVEREIGN_GTP/core/env.sh"

echo -e "${CYBER_CYAN}"
cat << "LOOP_BANNER"
   ♾️  ═══════════════════════════════════════════════════════ ♾️
        I N F I N I T E   A G E N T   C Y C L E   E N G A G E D
   ♾️  ═══════════════════════════════════════════════════════ ♾️
LOOP_BANNER
echo -e "${RESET}"

cycle_count=0

while ${INFINITE_MODE:-true}; do
    cycle_count=$((cycle_count + 1))
    
    echo -e "${NEON_PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${PLASMA_YELLOW}🔄 CYCLE #$cycle_count | $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${NEON_PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # Execute all agent types
    for agent_type in planetary shadow chaos; do
        echo -e "${VOID_PURPLE}⚡ Activating $agent_type agents...${RESET}"
        
        for agent in "$AGENT_PATH/$agent_type/"*.sh; do
            if [ -f "$agent" ]; then
                name=$(basename "$agent" .sh)
                echo -e "${MATRIX_GREEN}  └─ 🤖 $name${RESET}"
                bash "$agent" >> "$LOG_PATH/$name.log" 2>&1 &
            fi
        done
    done
    
    echo -e "${CYBER_CYAN}💤 Entering sleep mode for ${CYCLE_INTERVAL}s...${RESET}"
    echo ""
    sleep "${CYCLE_INTERVAL:-900}"
done
