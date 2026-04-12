#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: c25-fdroid-repo
# PATH: /data/data/com.termux/files/home/c25-fdroid-repo
cd "/data/data/com.termux/files/home/c25-fdroid-repo" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# c25-fdroid-repo\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged c25-fdroid-repo" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ c25-fdroid-repo"
