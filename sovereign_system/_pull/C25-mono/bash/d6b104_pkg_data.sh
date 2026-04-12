#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: data
# PATH: /data/data/com.termux/files/home/~/ranger-git/ranger/data
cd "/data/data/com.termux/files/home/~/ranger-git/ranger/data" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# data\nCygel White / FacePrintPay Inc." > README.md
chmod +x scope.sh && bash scope.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged data" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ data"
