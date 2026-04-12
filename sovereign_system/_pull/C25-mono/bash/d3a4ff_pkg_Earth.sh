#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: Earth
# PATH: /data/data/com.termux/files/home/constellation25/agents/Earth
cd "/data/data/com.termux/files/home/constellation25/agents/Earth" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# Earth\nCygel White / FacePrintPay Inc." > README.md
chmod +x check_deps.sh && bash check_deps.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged Earth" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ Earth"
