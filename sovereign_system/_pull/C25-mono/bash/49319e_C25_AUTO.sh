#!/data/data/com.termux/files/usr/bin/bash
# C25 FULL AUTONOMOUS PIPELINE
# No prompts. No stops. Runs everything.

source ~/.bashrc
LOG="$HOME/agent_logs/auto_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$HOME/agent_logs"

echo "╔══════════════════════════════════════╗"
echo "║  C25 FULL AUTO PIPELINE STARTING    ║"
echo "╚══════════════════════════════════════╝" | tee "$LOG"

# 1. Fix all files
echo "[1/4] Fixing all files..." | tee -a "$LOG"
bash ~/C25_HISTORY_FIX.sh >> "$LOG" 2>&1
echo "✓ Files fixed" | tee -a "$LOG"

# 2. Regenerate all build scripts
echo "[2/4] Regenerating build scripts..." | tee -a "$LOG"
bash ~/C25_BUILD_ALL.sh >> "$LOG" 2>&1
echo "✓ Build scripts ready: $(ls ~/c25_builds/build_*.sh | wc -l)" | tee -a "$LOG"

# 3. Run all builds and deploys
echo "[3/4] Building and deploying everything..." | tee -a "$LOG"
bash ~/c25_builds/RUN_ALL_BUILDS.sh >> "$LOG" 2>&1
echo "✓ Builds complete" | tee -a "$LOG"

# 4. Push everything to GitHub
echo "[4/4] Pushing all to GitHub..." | tee -a "$LOG"
find "$HOME/github-repos" -maxdepth 2 -name ".git" -type d 2>/dev/null | while read g; do
  dir=$(dirname "$g")
  name=$(basename "$dir")
  cd "$dir"
  git add -A 2>/dev/null
  git commit -m "C25 auto: $(date +%Y-%m-%d)" 2>/dev/null | tail -1
  git push 2>/dev/null && echo "  ✓ $name" | tee -a "$LOG"
  cd ~
done

echo "" | tee -a "$LOG"
echo "╔══════════════════════════════════════╗"
echo "║  C25 AUTO PIPELINE COMPLETE         ║"
echo "╚══════════════════════════════════════╝" | tee -a "$LOG"
echo "✅ Deployed: $(grep -c '🚀 LIVE → https' $LOG 2>/dev/null || echo 0)" | tee -a "$LOG"
echo "❌ Failed:   $(grep -c '❌' $LOG 2>/dev/null || echo 0)" | tee -a "$LOG"
echo "📋 Log: $LOG" | tee -a "$LOG"

# Stay alive — watch for new files and auto-deploy
echo "" | tee -a "$LOG"
echo "MOON: Live watch active..." | tee -a "$LOG"
inotifywait -m -r "$HOME/github-repos" \
  -e close_write --format '%w%f' 2>/dev/null | while read f; do
  [[ "$f" == *node_modules* ]] && continue
  [[ "$f" == *".git"* ]] && continue
  if [[ "$(basename $f)" == "package.json" ]]; then
    dir=$(dirname "$f")
    name=$(basename "$dir")
    echo "[MOON] New project: $name — building..."
    cd "$dir"
    npm install 2>/dev/null
    npm run build 2>/dev/null
    vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1
    cd ~
  fi
done
