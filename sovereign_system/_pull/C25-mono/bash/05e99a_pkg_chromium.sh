#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: chromium
# PATH: /data/data/com.termux/files/home/github-repos/Constellation25/ai-web-extensions/chatgpt-auto-continue/pages/welcome/chromium
cd "/data/data/com.termux/files/home/github-repos/Constellation25/ai-web-extensions/chatgpt-auto-continue/pages/welcome/chromium" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# chromium\nCygel White / FacePrintPay Inc." > README.md
vercel --yes --prod 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged chromium" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ chromium"
