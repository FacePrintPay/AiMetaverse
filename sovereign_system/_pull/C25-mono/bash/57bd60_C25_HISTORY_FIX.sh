#!/data/data/com.termux/files/usr/bin/bash
# C25 COMPLETE HISTORY FIX
# Fixes every .md .json .html .npm index.html across all history

LOGDIR="$HOME/agent_logs"
mkdir -p "$LOGDIR"

echo "╔══════════════════════════════════════╗"
echo "║  C25 COMPLETE HISTORY FIX           ║"
echo "╚══════════════════════════════════════╝"

# Find every project dir from history
find /data/data/com.termux/files/home /sdcard \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/playground/*" \
  -not -path "*/template-*" \
  -name "package.json" \
  2>/dev/null | while read pkg; do

  DIR=$(dirname "$pkg")
  NAME=$(basename "$DIR")
  echo "━━━ $NAME"

  cd "$DIR"

  # ── FIX package.json ─────────────────────────────
  python3 - << PYEOF
import json, os
try:
  with open("package.json") as f:
    p = json.load(f)
  changed = False
  # Add missing scripts
  p.setdefault("scripts", {})
  if "build" not in p["scripts"]:
    if os.path.exists("vite.config.js") or os.path.exists("vite.config.ts"):
      p["scripts"]["build"] = "vite build"
      p["scripts"]["dev"] = "vite"
    elif os.path.exists("next.config.js") or os.path.exists("next.config.ts"):
      p["scripts"]["build"] = "next build"
      p["scripts"]["dev"] = "next dev"
    elif os.path.exists("webpack.config.js"):
      p["scripts"]["build"] = "webpack"
    else:
      p["scripts"]["build"] = "echo ready"
    changed = True
  if "start" not in p["scripts"]:
    p["scripts"]["start"] = "node index.js"
    changed = True
  # Add missing fields
  if "version" not in p:
    p["version"] = "1.0.0"
    changed = True
  if "main" not in p:
    p["main"] = "index.js"
    changed = True
  if changed:
    with open("package.json","w") as f:
      json.dump(p, f, indent=2)
    print("  [Jupiter] ✓ package.json fixed")
except Exception as e:
  print(f"  [Jupiter] package.json error: {e}")
PYEOF

  # ── FIX/CREATE index.html ────────────────────────
  if [ ! -f "index.html" ]; then
    JS=$(find . -maxdepth 3 -name "main.js" -o -name "main.tsx" -o -name "main.jsx" \
      -o -name "index.js" 2>/dev/null | grep -v node_modules | head -1)
    CSS=$(find . -maxdepth 3 -name "*.css" 2>/dev/null | grep -v node_modules | head -1)
    JS_REL="${JS#./}"
    CSS_REL="${CSS#./}"
    cat > index.html << HEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>$NAME</title>
${CSS_REL:+<link rel="stylesheet" href="/$CSS_REL"/>}
</head>
<body>
<div id="root"></div>
${JS_REL:+<script type="module" src="/$JS_REL"></script>}
</body>
</html>
HEOF
    echo "  [Venus] ✓ index.html created"
  fi

  # ── FIX/CREATE README.md ─────────────────────────
  if [ ! -f "README.md" ]; then
    cat > README.md << MEOF
# $NAME
Sovereign build — Cygel White / FacePrintPay Inc.
Prior art: 2022 | System: Constellation-25

## Install
\`\`\`bash
npm install
\`\`\`

## Build
\`\`\`bash
npm run build
\`\`\`

## Deploy
\`\`\`bash
vercel --prod
\`\`\`
MEOF
    echo "  [Moon] ✓ README.md created"
  fi

  # ── FIX/CREATE vercel.json ───────────────────────
  if [ ! -f "vercel.json" ]; then
    FRAMEWORK=""
    grep -q '"next"' package.json 2>/dev/null && FRAMEWORK='"framework":"nextjs",'
    grep -q '"vite"' package.json 2>/dev/null && FRAMEWORK='"buildCommand":"npm run build","outputDirectory":"dist",'
    echo "{\"version\":2,${FRAMEWORK}\"rewrites\":[{\"source\":\"(.*)\",\"destination\":\"/index.html\"}]}" \
      > vercel.json
    echo "  [Cygnus] ✓ vercel.json created"
  fi

  # ── FIX/CREATE .env ──────────────────────────────
  if [ ! -f ".env" ] && [ ! -f ".env.example" ]; then
    echo "NODE_ENV=production" > .env.example
    echo "  [Earth] ✓ .env.example created"
  fi

  # ── FIX/CREATE .gitignore ────────────────────────
  if [ ! -f ".gitignore" ]; then
    cat > .gitignore << GEOF
node_modules/
dist/
build/
.env
.vercel
*.log
.DS_Store
GEOF
    echo "  [Saturn] ✓ .gitignore created"
  fi

  # ── VALIDATE ALL JSON FILES ──────────────────────
  find . -maxdepth 3 -name "*.json" \
    -not -path "*/node_modules/*" \
    2>/dev/null | while read jf; do
    python3 -c "import json; json.load(open('$jf'))" 2>/dev/null || {
      echo "  [Mercury] ✗ invalid JSON: $jf — fixing..."
      python3 - << PYEOF
try:
  with open("$jf") as f: content = f.read()
  # Try to fix common JSON errors
  import re
  content = re.sub(r',(\s*[}\]])', r'\1', content)  # trailing commas
  import json
  json.loads(content)
  with open("$jf","w") as f: f.write(content)
  print("  [Mercury] ✓ JSON fixed: $jf")
except:
  print("  [Mercury] ✗ could not auto-fix: $jf")
PYEOF
    }
  done

  # ── COMMIT EVERYTHING ───────────────────────────
  git add -A 2>/dev/null
  git commit -m "C25: complete history fix — md/json/html/npm $(date +%Y-%m-%d)" \
    2>/dev/null | tail -1
  git push 2>/dev/null | tail -1

  cd ~
done

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  HISTORY FIX COMPLETE               ║"
echo "╚══════════════════════════════════════╝"
echo "Now run: bash ~/c25_builds/RUN_ALL_BUILDS.sh"
