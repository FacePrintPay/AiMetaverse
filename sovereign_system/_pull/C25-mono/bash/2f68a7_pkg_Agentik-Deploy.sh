#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: Agentik-Deploy
# PATH: /data/data/com.termux/files/home/repos/constellation25-mono/Agentik/Agentik-Deploy
cd "/data/data/com.termux/files/home/repos/constellation25-mono/Agentik/Agentik-Deploy" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# Agentik-Deploy\nCygel White / FacePrintPay Inc." > README.md
chmod +x run.sh && bash run.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged Agentik-Deploy" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ Agentik-Deploy"
