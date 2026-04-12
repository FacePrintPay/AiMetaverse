#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: testgui
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/MatrixOS/tools/uf2/hidapi/testgui
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/MatrixOS/tools/uf2/hidapi/testgui" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# testgui\nCygel White / FacePrintPay Inc." > README.md
chmod +x copy_to_bundle.sh && bash copy_to_bundle.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged testgui" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ testgui"
