#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

MONO="$HOME/AiKre8tive_ONE/monorepo"
PA="$HOME/PlanetaryAgents"

# Your agents (edit this list anytime)
AGENTS=(
  "mercury"
  "venus"
  "earth"
  "mars"
  "jupiter"
  "saturn"
  "uranus"
  "neptune"
  "pluto"
)

mkdir -p "$PA/taskboxes" "$PA/logs"

for a in "${AGENTS[@]}"; do
  mkdir -p "$PA/taskboxes/$a"/{inbox,done,fail}
done

# Start each runner in its own tmux session
for a in "${AGENTS[@]}"; do
  if tmux has-session -t "PA_$a" 2>/dev/null; then
    echo "🟡 Already running: $a"
    continue
  fi
  echo "🟢 Starting: $a"
  tmux new-session -d -s "PA_$a" "$PA/bin/taskbox_runner.sh $a $MONO"
done

echo "✅ Planetary stack is up."
echo "Tip: tmux ls"
