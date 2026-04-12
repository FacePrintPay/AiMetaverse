#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: .c25
# PATH: /data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.c25
cd "/data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.c25" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# .c25\nCygel White / FacePrintPay Inc." > README.md
chmod +x bridge-server.sh && bash bridge-server.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged .c25" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ .c25"
