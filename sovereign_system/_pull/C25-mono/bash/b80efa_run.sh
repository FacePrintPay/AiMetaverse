#!/bin/bash
echo "[$(date)] $(basename $PWD): Running with args: $*" >> ~/Agentik/logs/$(basename $PWD).log
sleep 5
echo "[$(date)] $(basename $PWD): Task completed." >> ~/Agentik/logs/$(basename $PWD).log
