#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: docker-compose
# PATH: /data/data/com.termux/files/home/repos/data-api/docker-compose
cd "/data/data/com.termux/files/home/repos/data-api/docker-compose" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# docker-compose\nCygel White / FacePrintPay Inc." > README.md
chmod +x start_dse69.sh && bash start_dse69.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged docker-compose" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ docker-compose"
