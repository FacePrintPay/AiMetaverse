#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: STACK
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Home/STACK
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Home/STACK" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# STACK\nCygel White / FacePrintPay Inc." > README.md
chmod +x load_stacks.sh && bash load_stacks.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged STACK" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ STACK"
