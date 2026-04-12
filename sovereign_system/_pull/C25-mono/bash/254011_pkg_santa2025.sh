#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: santa2025
# PATH: /data/data/com.termux/files/home/repos/WideOpen-Obsidian/Termux_Backup_20251227_231515/scripts/data/data/com.termux/files/home/santa2025
cd "/data/data/com.termux/files/home/repos/WideOpen-Obsidian/Termux_Backup_20251227_231515/scripts/data/data/com.termux/files/home/santa2025" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# santa2025\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged santa2025" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ santa2025"
