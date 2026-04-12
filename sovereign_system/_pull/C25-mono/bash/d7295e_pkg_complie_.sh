#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: complie_
# PATH: /.obsidian/AiKre8tive/.obsidian/complie 
cd "/.obsidian/AiKre8tive/.obsidian/complie " 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# complie_\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged complie_" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ complie_"
