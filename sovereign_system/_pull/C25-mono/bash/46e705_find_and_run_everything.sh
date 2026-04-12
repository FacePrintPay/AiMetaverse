#!/usr/bin/env bash
set -e

export HOME="/data/data/com.termux/files/home"
cd "$HOME" || exit 1

LOG="$HOME/find_and_run.log"
> "$LOG"

echo "🔎 FIND & RUN — starting $(date)" | tee -a "$LOG"
echo "🏠 HOME: $HOME" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Absolute exclusions (DO NOT TOUCH)
EXCLUDES=(
  "$HOME/.npm"
  "$HOME/.cache"
  "$HOME/.termux"
  "$HOME/storage"
  "$HOME/shared"
)

should_exclude() {
  for e in "${EXCLUDES[@]}"; do
    [[ "$1" == "$e"* ]] && return 0
  done
  return 1
}

# FIND EVERYTHING YOU OWN
find "$HOME" -type f 2>/dev/null | while read -r file; do
  should_exclude "$file" && continue

  case "$file" in
    *.sh|*.py|*.js)
      echo "📌 Candidate: $file" | tee -a "$LOG"
      ;;
    *)
      if [ -x "$file" ]; then
        echo "📌 Executable: $file" | tee -a "$LOG"
      fi
      ;;
  esac
done

echo "" | tee -a "$LOG"
echo "🚀 EXECUTION PHASE" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# RUN PHASE
find "$HOME" -type f 2>/dev/null | while read -r file; do
  should_exclude "$file" && continue

  if [ -x "$file" ]; then
    echo "▶ Running executable: $file" | tee -a "$LOG"
    "$file" >> "$LOG" 2>&1 || echo "⚠ Failed: $file" | tee -a "$LOG"
    echo "" | tee -a "$LOG"

  elif [[ "$file" == *.sh ]]; then
    echo "▶ bash $file" | tee -a "$LOG"
    bash "$file" >> "$LOG" 2>&1 || echo "⚠ Failed: $file" | tee -a "$LOG"
    echo "" | tee -a "$LOG"

  elif [[ "$file" == *.py ]]; then
    echo "▶ python $file" | tee -a "$LOG"
    python "$file" >> "$LOG" 2>&1 || echo "⚠ Failed: $file" | tee -a "$LOG"
    echo "" | tee -a "$LOG"

  elif [[ "$file" == *.js ]]; then
    if command -v node >/dev/null 2>&1; then
      echo "▶ node $file" | tee -a "$LOG"
      node "$file" >> "$LOG" 2>&1 || echo "⚠ Failed: $file" | tee -a "$LOG"
      echo "" | tee -a "$LOG"
    fi
  fi
done

echo "✅ DONE — $(date)" | tee -a "$LOG"
