#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: fp-build-fixer
# PATH: /data/data/com.termux/files/home/repos/constellation25-mono/fp-build-fixer
cd "/data/data/com.termux/files/home/repos/constellation25-mono/fp-build-fixer" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# fp-build-fixer\nCygel White / FacePrintPay Inc." > README.md
chmod +x build-fixer-agent.sh && bash build-fixer-agent.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged fp-build-fixer" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ fp-build-fixer"
