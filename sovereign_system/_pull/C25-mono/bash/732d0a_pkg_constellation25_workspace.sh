#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: constellation25_workspace
# PATH: /data/data/com.termux/files/home/constellation25_workspace
cd "/data/data/com.termux/files/home/constellation25_workspace" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# constellation25_workspace\nCygel White / FacePrintPay Inc." > README.md
chmod +x constellation_consolidator.sh && bash constellation_consolidator.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged constellation25_workspace" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ constellation25_workspace"
