#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# FORCE CANONICAL HOME
# ─────────────────────────────────────────────
export HOME="/data/data/com.termux/files/home"
cd "$HOME" || exit 1

echo "🏠 HOME locked to: $HOME"
echo "▶ Running executable files in HOME"
echo ""

# ─────────────────────────────────────────────
# RUN ALL EXECUTABLE FILES IN HOME
# (excluding this script itself)
# ─────────────────────────────────────────────
for f in "$HOME"/*; do
  if [[ -f "$f" && -x "$f" && "$f" != "$HOME/run_all_home.sh" ]]; then
    echo "🚀 Running: $f"
    "$f" || echo "⚠️ Failed: $f"
    echo ""
  fi
done

echo "✅ Done running HOME executables"
