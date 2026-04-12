#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: boot
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Home/.termux/boot
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Home/.termux/boot" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# boot\nCygel White / FacePrintPay Inc." > README.md
chmod +x planetary_start.sh && bash planetary_start.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged boot" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ boot"
