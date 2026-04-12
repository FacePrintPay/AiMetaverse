#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: c25-sovereign-launch
# PATH: /data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/c25-sovereign-launch
cd "/data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/c25-sovereign-launch" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# c25-sovereign-launch\nCygel White / FacePrintPay Inc." > README.md
chmod +x sovereign_launch.sh && bash sovereign_launch.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged c25-sovereign-launch" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ c25-sovereign-launch"
