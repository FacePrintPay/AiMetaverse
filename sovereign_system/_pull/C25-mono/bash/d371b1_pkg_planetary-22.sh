#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: planetary-22
# PATH: /data/data/com.termux/files/home/Constellation25/agents/planetary-22
cd "/data/data/com.termux/files/home/Constellation25/agents/planetary-22" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# planetary-22\nCygel White / FacePrintPay Inc." > README.md
chmod +x agent-core.sh && bash agent-core.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged planetary-22" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ planetary-22"
