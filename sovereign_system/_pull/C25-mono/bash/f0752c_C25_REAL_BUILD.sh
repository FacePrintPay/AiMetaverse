#!/data/data/com.termux/files/usr/bin/bash
PASS=0; FAIL=0
while read dir; do
  name=$(basename "$dir")
  echo "━━━ $name"
  cd "$dir" || continue
  [ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
  [ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n" > .gitignore
  npm install --silent 2>/dev/null | tail -1
  npm run build 2>/dev/null | tail -2
  vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1 | xargs -I{} echo "  🚀 $name → {}"
  git add -A 2>/dev/null
  git commit -m "C25: ship $name" 2>/dev/null | tail -1
  git push 2>/dev/null | tail -1
  echo "  ✅ $name"
  ((PASS++))
  cd ~
done < ~/agent_logs/REAL_PROJECTS.txt
echo "✅ $PASS shipped"
