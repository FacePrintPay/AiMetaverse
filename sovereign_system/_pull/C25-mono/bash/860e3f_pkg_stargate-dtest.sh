#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: stargate-dtest
# PATH: /data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/sovereign_20251223_022254/repos/stargate-dtest
cd "/data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/sovereign_20251223_022254/repos/stargate-dtest" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# stargate-dtest\nCygel White / FacePrintPay Inc." > README.md
pip install -r requirements.txt --break-system-packages -q 2>/dev/null

git add -A 2>/dev/null
git commit -m "C25: packaged stargate-dtest" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ stargate-dtest"
