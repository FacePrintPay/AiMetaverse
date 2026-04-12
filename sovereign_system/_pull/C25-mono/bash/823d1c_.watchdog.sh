#!/usr/bin/env bash
while true; do
    if ! pgrep -f "agent.sh" > /dev/null; then
        log "Agent not running — restarting..."
        nohup bash "${HOME}/Constellation25/agent.sh" </dev/null >/dev/null 2>&1 &
    fi
    sleep 60   # much gentler — 60s instead of 17s
done
