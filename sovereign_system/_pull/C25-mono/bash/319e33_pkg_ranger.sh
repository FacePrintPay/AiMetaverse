#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: ranger
# PATH: /data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.config/ranger
cd "/data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/Obsidian/C25-Archive-20260316_193027/termux-home/home/.config/ranger" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# ranger\nCygel White / FacePrintPay Inc." > README.md
chmod +x scope.sh && bash scope.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged ranger" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ ranger"
