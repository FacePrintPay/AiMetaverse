#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: .agent-engine
# PATH: /data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.agent-engine
cd "/data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.agent-engine" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# .agent-engine\nCygel White / FacePrintPay Inc." > README.md
chmod +x engine.sh && bash engine.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged .agent-engine" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ .agent-engine"
