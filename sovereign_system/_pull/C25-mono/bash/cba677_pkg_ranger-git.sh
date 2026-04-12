#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: ranger-git
# PATH: /data/data/com.termux/files/home/~/ranger-git
cd "/data/data/com.termux/files/home/~/ranger-git" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# ranger-git\nCygel White / FacePrintPay Inc." > README.md
pip install -r requirements.txt --break-system-packages -q 2>/dev/null

git add -A 2>/dev/null
git commit -m "C25: packaged ranger-git" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ ranger-git"
