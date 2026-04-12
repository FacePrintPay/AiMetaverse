#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: VeRseD_Ai
# PATH: /data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/VeRseD_Ai
cd "/data/data/com.termux/files/home/CONSTELLATION25_CODEBASE/FacePrintPay/VeRseD_Ai" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# VeRseD_Ai\nCygel White / FacePrintPay Inc." > README.md
chmod +x key_rotate.sh && bash key_rotate.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged VeRseD_Ai" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ VeRseD_Ai"
