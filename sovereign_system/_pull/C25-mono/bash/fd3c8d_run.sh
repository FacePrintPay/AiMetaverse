#!/data/data/com.termux/files/usr/bin/bash
# C25 AGENT RUNNER — antora-ui-stargate
C25_HOME="$HOME/constellation25"
mkdir -p "$C25_HOME/logs"
ts() { date '+%Y-%m-%d %H:%M:%S'; }
echo "[$(ts)] [C25] [antora-ui-stargate] START" | tee -a "$C25_HOME/logs/antora-ui-stargate.log"
echo "[$(ts)] [antora-ui-stargate] SHA256:$(printf '%s' "antora-ui-stargate$(ts)" | sha256sum | cut -d' ' -f1)" >> "$C25_HOME/logs/totalrecall_manifest.log"
[ -f "$(dirname $0)/index.js" ] && node "$(dirname $0)/index.js" "$@" && exit
[ -f "$(dirname $0)/main.py" ]  && python3 "$(dirname $0)/main.py" "$@" && exit
echo "[$(ts)] [antora-ui-stargate] PROPOSE: no entry point — human approval required"
