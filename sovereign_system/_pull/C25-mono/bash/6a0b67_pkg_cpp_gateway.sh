#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: cpp_gateway
# PATH: /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/aikre8tive/cpp_gateway
cd "/data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/repos/aikre8tive/cpp_gateway" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# cpp_gateway\nCygel White / FacePrintPay Inc." > README.md
chmod +x run_gateway.sh && bash run_gateway.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged cpp_gateway" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ cpp_gateway"
