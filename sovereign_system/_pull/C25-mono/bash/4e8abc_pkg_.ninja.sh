#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: .ninja
# PATH: /data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/SOVEREIGN_PORTFOLIO_1M/TheKre8tive/agentik/$HOME/.ninja
cd "/data/data/com.termux/files/home/phone_clone/hidden/storage/emulated/0/SOVEREIGN_PORTFOLIO_1M/TheKre8tive/agentik/$HOME/.ninja" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# .ninja\nCygel White / FacePrintPay Inc." > README.md
chmod +x reset.sh && bash reset.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged .ninja" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ .ninja"
