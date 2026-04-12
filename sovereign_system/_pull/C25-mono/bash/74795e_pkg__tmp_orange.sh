#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: _tmp_orange
# PATH: /data/data/com.termux/files/home/github-repos/Constellation25/_tmp_orange
cd "/data/data/com.termux/files/home/github-repos/Constellation25/_tmp_orange" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# _tmp_orange\nCygel White / FacePrintPay Inc." > README.md
vercel --yes --prod 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged _tmp_orange" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ _tmp_orange"
