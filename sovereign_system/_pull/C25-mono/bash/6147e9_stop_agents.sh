#!/data/data/com.termux/files/usr/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}Stopping all agents...${NC}"

pkill -f "_agent.py" && echo -e "${GREEN}✅ Agents stopped${NC}" || echo "No agents running"
