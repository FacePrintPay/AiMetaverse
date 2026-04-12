#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: assistants
# PATH: /data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/c25-agent-deploy/ai_metaverse/assistants
cd "/data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/c25-agent-deploy/ai_metaverse/assistants" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# assistants\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged assistants" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ assistants"
