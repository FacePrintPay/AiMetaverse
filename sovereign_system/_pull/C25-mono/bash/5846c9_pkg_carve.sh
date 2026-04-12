#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: carve
# PATH: /data/data/com.termux/files/home/repos/WideOpen-Obsidian/Termux_Backup_20251227_231515/scripts/data/data/com.termux/files/home/monorepo/tools/carve
cd "/data/data/com.termux/files/home/repos/WideOpen-Obsidian/Termux_Backup_20251227_231515/scripts/data/data/com.termux/files/home/monorepo/tools/carve" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# carve\nCygel White / FacePrintPay Inc." > README.md
chmod +x carve_pdfs_poppler.sh && bash carve_pdfs_poppler.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged carve" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ carve"
