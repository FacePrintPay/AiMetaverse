#!/bin/bash
set -euo pipefail

# One-time presale blast
if [[ ! -f ~/Agentik/presale_done ]]; then
  echo "Blasting presale offers..."
  ~/Agentik/agentctl.sh start Agentik-Outreach blast_presale
  touch ~/Agentik/presale_done
fi

# Perpetual deposit monitoring
while true; do
  ~/Agentik/agentctl.sh start Agentik-Outreach monitor_deposits
  sleep 300  # check every 5 minutes
done
