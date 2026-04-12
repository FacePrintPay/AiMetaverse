#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="sirius"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  AGENT_COUNT=$(ls "$C25/agents/"*.pid 2>/dev/null | wc -l)
  echo "[$TS] [$NAME] DEPLOY_STATUS active_agents:$AGENT_COUNT" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/sirius.log"
  sleep 120
done
