#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: unified-build
# PATH: /data/data/com.termux/files/home/constellation25/unified-build
cd "/data/data/com.termux/files/home/constellation25/unified-build" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# unified-build\nCygel White / FacePrintPay Inc." > README.md
echo "Docker: unified-build ready"

git add -A 2>/dev/null
git commit -m "C25: packaged unified-build" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ unified-build"
