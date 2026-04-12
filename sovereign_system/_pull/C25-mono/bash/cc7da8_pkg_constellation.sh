#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: constellation
# PATH: /data/data/com.termux/files/home/Constellation25-v3.0-DEPLOY/constellation
cd "/data/data/com.termux/files/home/Constellation25-v3.0-DEPLOY/constellation" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# constellation\nCygel White / FacePrintPay Inc." > README.md
vercel --yes --prod 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged constellation" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ constellation"
