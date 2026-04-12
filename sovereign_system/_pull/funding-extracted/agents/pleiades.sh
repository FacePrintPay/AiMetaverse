#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="pleiades"
VENVS="$C25/venvs"
mkdir -p "$VENVS"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  VENV_COUNT=$(ls -d "$VENVS"/*/  2>/dev/null | wc -l)
  echo "[$TS] [$NAME] VENV_STATUS count:$VENV_COUNT" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/pleiades.log"
  sleep 300
done
