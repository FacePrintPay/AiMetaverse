#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: RepoDepot-Stargate
# PATH: /data/data/com.termux/files/home/repos/RepoDepot-Stargate
cd "/data/data/com.termux/files/home/repos/RepoDepot-Stargate" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# RepoDepot-Stargate\nCygel White / FacePrintPay Inc." > README.md
chmod +x kre8tive_portfolio_build.sh && bash kre8tive_portfolio_build.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged RepoDepot-Stargate" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ RepoDepot-Stargate"
