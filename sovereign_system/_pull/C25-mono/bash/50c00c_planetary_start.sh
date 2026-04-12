#!/data/data/com.termux/files/usr/bin/bash
# give the phone a second to settle
sleep 8
$HOME/PlanetaryAgents/bin/start_stack.sh >> $HOME/PlanetaryAgents/logs/boot.log 2>&1
