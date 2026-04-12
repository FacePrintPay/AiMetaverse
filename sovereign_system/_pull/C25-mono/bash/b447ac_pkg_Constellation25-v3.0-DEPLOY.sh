#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: Constellation25-v3.0-DEPLOY
# PATH: /data/data/com.termux/files/home/Constellation25-v3.0-DEPLOY
cd "/data/data/com.termux/files/home/Constellation25-v3.0-DEPLOY" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# Constellation25-v3.0-DEPLOY\nCygel White / FacePrintPay Inc." > README.md
chmod +x run.sh && bash run.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged Constellation25-v3.0-DEPLOY" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ Constellation25-v3.0-DEPLOY"
