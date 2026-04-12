#!/data/data/com.termux/files/usr/bin/bash
# C25 PLANETARY AGENTS — BUILD SCRIPTS FOR ALL REPOS
# Mercury=routing Venus=UI Mars=build Jupiter=scale Earth=data Moon=memory

LOGDIR="$HOME/agent_logs"
BUILDS="$HOME/c25_builds"
mkdir -p "$LOGDIR" "$BUILDS"

echo "╔══════════════════════════════════════╗"
echo "║  C25 PLANETARY BUILD GENERATOR      ║"
echo "╚══════════════════════════════════════╝"

# MERCURY — route each repo to right agent
find /data/data/com.termux/files/home /sdcard \
  -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/playground/*" \
  -not -path "*/template-*" \
  -not -path "*/.git/*" \
  2>/dev/null | while read pkg; do

  DIR=$(dirname "$pkg")
  NAME=$(basename "$DIR" | tr ' ' '-' | tr -cd '[:alnum:]-_')
  SCRIPT="$BUILDS/build_${NAME}.sh"

  # Detect framework
  FRAMEWORK="static"
  grep -q '"vite"'    "$pkg" 2>/dev/null && FRAMEWORK="vite"
  grep -q '"next"'    "$pkg" 2>/dev/null && FRAMEWORK="nextjs"
  grep -q '"react"'   "$pkg" 2>/dev/null && FRAMEWORK="react"
  grep -q '"express"' "$pkg" 2>/dev/null && FRAMEWORK="express"
  grep -q '"build"'   "$pkg" 2>/dev/null || FRAMEWORK="nobuild"

  # MARS — write build script per project
  cat > "$SCRIPT" << BEOF
#!/data/data/com.termux/files/usr/bin/bash
# PROJECT: $NAME
# FRAMEWORK: $FRAMEWORK
# PATH: $DIR
# AGENT: Mars
# GENERATED: $(date)

echo "━━━ Mars building: $NAME [$FRAMEWORK]"
cd "$DIR" || exit 1

# Venus — fix missing UI files
[ ! -f "index.html" ] && cat > index.html << 'HEOF'
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>$NAME</title>
<link rel="stylesheet" href="style.css"/>
</head><body><div id="root"></div>
<script type="module" src="main.js"></script>
</body></html>
HEOF

[ ! -f "style.css" ] && echo "/* $NAME styles */body{margin:0;font-family:sans-serif;background:#0a0a0f;color:#f8fafc}" > style.css

# Earth — fix missing config files
[ ! -f ".env" ]        && echo "NODE_ENV=production" > .env
[ ! -f ".gitignore" ]  && echo "node_modules/\ndist/\n.env" > .gitignore
[ ! -f "vercel.json" ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json

# Jupiter — install dependencies
echo "  [Jupiter] Installing..."
npm install 2>&1 | tail -3

# Fix rollup ARM64 if needed
npm run build 2>&1 | grep -q "rollup-android-arm64" && {
  echo "  [Mars] Fixing rollup ARM64..."
  rm -rf node_modules package-lock.json
  npm install --ignore-scripts 2>&1 | tail -3
}

BEOF

  # Add build step based on framework
  case "$FRAMEWORK" in
    vite|react)
      cat >> "$SCRIPT" << 'BEOF'
echo "  [Mars] Vite build..."
npm run build 2>&1 | tail -5
BUILD_OK=$?
BEOF
      ;;
    nextjs)
      cat >> "$SCRIPT" << 'BEOF'
echo "  [Mars] Next.js build..."
npm run build 2>&1 | tail -5
BUILD_OK=$?
BEOF
      ;;
    express)
      cat >> "$SCRIPT" << 'BEOF'
echo "  [Mars] Express — no build needed"
BUILD_OK=0
BEOF
      ;;
    nobuild)
      cat >> "$SCRIPT" << 'BEOF'
echo "  [Mars] No build script — deploying direct"
BUILD_OK=0
BEOF
      ;;
    *)
      cat >> "$SCRIPT" << 'BEOF'
echo "  [Mars] Static — deploying direct"
BUILD_OK=0
BEOF
      ;;
  esac

  # Add deploy + git push
  cat >> "$SCRIPT" << 'BEOF'

# Saturn — git commit and push
echo "  [Saturn] Pushing to GitHub..."
git add -A 2>/dev/null
git commit -m "C25 Mars: build + fix $(date +%Y-%m-%d)" 2>/dev/null || true
git push 2>/dev/null || true

# Cygnus — deploy to Vercel
echo "  [Cygnus] Deploying..."
vercel --yes --prod -e NODE_ENV=production 2>&1 | tail -1 | \
  xargs -I{} echo "  🚀 LIVE → {}"

echo "  ✅ DONE"
BEOF

  chmod +x "$SCRIPT"
  echo "  [Mercury] ✓ $NAME → $FRAMEWORK"

done

# MOON — write master runner
MASTER="$BUILDS/RUN_ALL_BUILDS.sh"
cat > "$MASTER" << 'MEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "C25 MASTER BUILD RUNNER"
echo "======================="
PASS=0; FAIL=0
MEOF

for s in "$BUILDS"/build_*.sh; do
  echo "bash $s && ((PASS++)) || ((FAIL++)) ; echo ''" >> "$MASTER"
done

cat >> "$MASTER" << 'MEOF'
echo "======================="
echo "✅ PASS: $PASS"
echo "❌ FAIL: $FAIL"
MEOF
chmod +x "$MASTER"

COUNT=$(ls "$BUILDS"/build_*.sh 2>/dev/null | wc -l)
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  BUILD SCRIPTS GENERATED            ║"
echo "╚══════════════════════════════════════╝"
echo "  Scripts: $COUNT"
echo "  Location: $BUILDS"
echo ""
echo "  Run ONE project:"
echo "  bash $BUILDS/build_PROJECTNAME.sh"
echo ""
echo "  Run ALL projects:"
echo "  bash $MASTER"
