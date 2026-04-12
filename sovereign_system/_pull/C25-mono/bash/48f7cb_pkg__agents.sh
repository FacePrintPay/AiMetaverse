#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: _agents
# PATH: /data/data/com.termux/files/home/github-repos/Constellation25/_agents
cd "/data/data/com.termux/files/home/github-repos/Constellation25/_agents" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# _agents\nCygel White / FacePrintPay Inc." > README.md
chmod +x build_trainer.sh && bash build_trainer.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged _agents" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ _agents"
