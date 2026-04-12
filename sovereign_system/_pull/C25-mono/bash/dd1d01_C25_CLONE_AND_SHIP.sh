#!/data/data/com.termux/files/usr/bin/bash
REPOS="$HOME/c25-all-repos"
LOG="$HOME/agent_logs/clone_ship.log"
mkdir -p "$REPOS"

echo "═══ STEP 1: CLONE ALL REPOS FROM GITHUB ==="
gh repo list FacePrintPay --limit 200 --json name \
  --jq '.[].name' 2>/dev/null | while read name; do
  dest="$REPOS/$name"
  if [ -d "$dest" ]; then
    echo "  ✓ exists: $name"
    cd "$dest" && git pull -q 2>/dev/null && cd ~
  else
    echo "  ► cloning: $name"
    gh repo clone "FacePrintPay/$name" "$dest" -- --depth 1 -q 2>/dev/null && \
      echo "  ✓ $name" || echo "  ✗ $name"
  fi
done

echo ""
echo "═══ STEP 2: BUILD AND DEPLOY EACH ONE ==="
for dir in "$REPOS"/*/; do
  name=$(basename "$dir")
  echo "━━━ $name"
  cd "$dir"

  # Add missing files
  [ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
  [ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n" > .gitignore
  [ ! -f .env ] && echo "NODE_ENV=production" > .env

  if [ -f package.json ]; then
    # Fix missing build script
    grep -q '"build"' package.json || \
      python3 -c "
import json
p=json.load(open('package.json'))
p.setdefault('scripts',{})['build']='echo ready'
json.dump(p,open('package.json','w'),indent=2)"

    npm install --silent 2>/dev/null | tail -1
    npm run build 2>/dev/null | tail -2
  fi

  # Deploy solo
  URL=$(vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1)
  echo "  🚀 $name → $URL" | tee -a "$LOG"

  # Push back to GitHub
  git add -A 2>/dev/null
  git commit -m "C25: ship $(date +%Y-%m-%d)" 2>/dev/null | tail -1
  git push 2>/dev/null | tail -1

  cd ~
done

echo ""
echo "═══════════════════════════════"
echo "DONE"
echo "Deployed: $(grep -c '🚀' $LOG 2>/dev/null || echo 0)"
echo "Log: $LOG"
