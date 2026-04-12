#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: ISSUE_TEMPLATE
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/bolt.new/.github/ISSUE_TEMPLATE
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/bolt.new/.github/ISSUE_TEMPLATE" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# ISSUE_TEMPLATE\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged ISSUE_TEMPLATE" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ ISSUE_TEMPLATE"
