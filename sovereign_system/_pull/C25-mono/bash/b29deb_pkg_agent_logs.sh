#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: agent_logs
# PATH: /data/data/com.termux/files/home/agent_logs
cd "/data/data/com.termux/files/home/agent_logs" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# agent_logs\nCygel White / FacePrintPay Inc." > README.md
chmod +x compiled_c25-autopush-scheduler.sh && bash compiled_c25-autopush-scheduler.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged agent_logs" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ agent_logs"
