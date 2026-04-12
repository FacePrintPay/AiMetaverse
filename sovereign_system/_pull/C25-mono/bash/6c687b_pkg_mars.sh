#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: mars
# PATH: /data/data/com.termux/files/home/agents/mars
cd "/data/data/com.termux/files/home/agents/mars" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# mars\nCygel White / FacePrintPay Inc." > README.md
chmod +x crawler.sh && bash crawler.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged mars" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ mars"
