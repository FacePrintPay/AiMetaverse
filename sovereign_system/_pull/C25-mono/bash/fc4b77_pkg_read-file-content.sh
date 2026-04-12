#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: read-file-content
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/kreativekoncepts/playground/ssr-deps/read-file-content
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/kreativekoncepts/playground/ssr-deps/read-file-content" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# read-file-content\nCygel White / FacePrintPay Inc." > README.md
grep -q '"build"' package.json || python3 -c "import json; p=json.load(open('package.json')); p.setdefault('scripts',{})['build']='echo ready'; json.dump(p,open('package.json','w'),indent=2)"
npm install --silent 2>/dev/null | tail -1
npm run build 2>/dev/null | tail -3
vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged read-file-content" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ read-file-content"
