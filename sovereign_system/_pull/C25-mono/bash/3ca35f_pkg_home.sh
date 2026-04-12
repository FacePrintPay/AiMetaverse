#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: home
# PATH: /data/data/com.termux/files/home
cd "/data/data/com.termux/files/home" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# home\nCygel White / FacePrintPay Inc." > README.md
chmod +x C25_AUTO.sh && bash C25_AUTO.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged home" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ home"
