#!/data/data/com.termux/files/usr/bin/bash
# C25 GAMMA AGENT
# Routes prompt through full gamma pipeline:
# PROMPT → NOTEBOOK LLM → BANANA → C25 AGENTS → ARTIFACT
C25_HOME="$HOME/constellation25"
GAMMA_SH="$C25_HOME/gamma.sh"
BANANA_PY="$C25_HOME/banana.py"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

PROMPT="${1:-}"
[ -z "$PROMPT" ] && { echo "Usage: gamma_agent.sh <prompt>"; exit 1; }

echo "[$(ts)] [GAMMA_AGENT] Routing: $PROMPT"

if [ -f "$GAMMA_SH" ]; then
  bash "$GAMMA_SH" "$PROMPT"
else
  echo "[$(ts)] [GAMMA_AGENT] ERROR: gamma.sh not found at $GAMMA_SH"
  echo "[$(ts)] [GAMMA_AGENT] PROPOSE: Deploy gamma.sh to $C25_HOME"
fi
