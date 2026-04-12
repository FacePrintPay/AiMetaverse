#!/data/data/com.termux/files/usr/bin/bash
LOGDIR="$HOME/agent_logs"
mkdir -p "$LOGDIR"

# Start Ollama
pkill ollama 2>/dev/null; sleep 1
ollama serve > "$LOGDIR/ollama.log" 2>&1 &
sleep 3
echo "Ollama: $(pgrep ollama > /dev/null && echo UP || echo FAILED)"

agent_fix() {
  local result=$(curl -s --max-time 30 http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"llama3\",\"prompt\":\"$1\",\"stream\":false}" 2>/dev/null)
  if [ -z "$result" ]; then
    echo "echo 'agent unavailable'"
    return
  fi
  echo "$result" | python3 -c "
import sys,json
try:
  print(json.load(sys.stdin).get('response','echo skip'))
except:
  print('echo skip')
" 2>/dev/null
}

fix_rollup() {
  cd "$1"
  rm -rf node_modules package-lock.json
  npm install --ignore-scripts 2>&1 | tail -3
  npm run build 2>&1
  cd ~
}

process_project() {
  local dir="$1"
  local name=$(basename "$dir")
  local log="$LOGDIR/${name}.log"
  echo "━━━ $name"
  cd "$dir"

  [ ! -f "vercel.json" ] && \
    echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
  [ ! -f ".env" ] && echo "NODE_ENV=production" > .env

  npm install 2>&1 | tail -2 | tee -a "$log"

  # Skip if no build script
  if ! grep -q '"build"' package.json 2>/dev/null; then
    echo "  ⚠ no build script — deploying as-is"
    vercel --yes --prod -e NODE_ENV=production 2>&1 | tail -1 | \
      xargs -I{} echo "  🚀 $name → {}"
    cd ~
    return
  fi

  BUILD_ERR=$(npm run build 2>&1)
  BUILD_OK=$?

  if [ $BUILD_OK -ne 0 ]; then
    if echo "$BUILD_ERR" | grep -q "rollup-android-arm64"; then
      echo "  [MARS] ARM64 rollup fix..."
      fix_rollup "$dir"
      BUILD_OK=$?
    else
      echo "  [MARS] Agent fixing..."
      FIX=$(agent_fix "Return ONLY bash commands to fix this error no explanation: ${BUILD_ERR: -500}")
      echo "$FIX" | bash 2>&1 | tee -a "$log"
      BUILD_ERR=$(npm run build 2>&1)
      BUILD_OK=$?
    fi
  fi

  if [ $BUILD_OK -eq 0 ]; then
    vercel --yes --prod -e NODE_ENV=production 2>&1 | tail -1 | \
      xargs -I{} echo "  🚀 $name LIVE → {}"
    echo "✅ $name" >> "$LOGDIR/SUCCESS.txt"
  else
    echo "  ❌ $name"
    echo "❌ $name" >> "$LOGDIR/FAILED.txt"
    echo "$BUILD_ERR" >> "$log"
  fi
  cd ~
}

echo "══════════════════════════════"
echo " C25 AGENTS — ALL PROJECTS"
echo "══════════════════════════════"

find /data/data/com.termux/files/home /sdcard \
  -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/playground/*" \
  -not -path "*/template-*" \
  -not -path "*/.git/*" \
  2>/dev/null | while read pkg; do
  process_project "$(dirname $pkg)"
done

echo ""
echo "══════════════════════════════"
echo "DONE. Results:"
echo "✅ $(wc -l < $LOGDIR/SUCCESS.txt 2>/dev/null || echo 0) deployed"
echo "❌ $(wc -l < $LOGDIR/FAILED.txt 2>/dev/null || echo 0) failed"
echo "Logs: $LOGDIR"
echo "══════════════════════════════"

inotifywait -m -r /data/data/com.termux/files/home /sdcard \
  -e create -e close_write --format '%w%f' 2>/dev/null | while read f; do
  [[ "$f" == *node_modules* ]] && continue
  [[ "$f" == *".git"* ]] && continue
  [[ "$(basename $f)" == "package.json" ]] && process_project "$(dirname $f)"
done
