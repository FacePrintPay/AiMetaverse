#!/data/data/com.termux/files/usr/bin/bash
source "$HOME/SOVEREIGN_GTP/core/env.sh"

echo -e "${VOID_PURPLE}╔═══════════════════════════════════╗${RESET}"
echo -e "${VOID_PURPLE}║   🛡️  SENTINEL: Defense Grid     ║${RESET}"
echo -e "${VOID_PURPLE}╚═══════════════════════════════════╝${RESET}"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# System monitoring
disk_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}')
mem_usage=$(free -h | grep Mem | awk '{print $3"/"$2}')

echo -e "${CYBER_CYAN}[$timestamp] Scanning perimeter...${RESET}"
echo -e "${MATRIX_GREEN}💾 Storage: $disk_usage used${RESET}"
echo -e "${MATRIX_GREEN}🧠 Memory: $mem_usage${RESET}"

# Threat assessment
if [ "${disk_usage%\%}" -gt 80 ]; then
    echo -e "${BLOOD_RED}⚠️  WARNING: Disk space critical!${RESET}"
fi

echo "$timestamp | Sentinel | Disk: $disk_usage | Mem: $mem_usage" >> "$MEMORY_PATH/sentinel.mem"
