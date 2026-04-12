#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: mybuyo-foodlion-mvp
# PATH: /data/data/com.termux/files/home/mybuyo-foodlion-mvp
cd "/data/data/com.termux/files/home/mybuyo-foodlion-mvp" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# mybuyo-foodlion-mvp\nCygel White / FacePrintPay Inc." > README.md
vercel --yes --prod 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged mybuyo-foodlion-mvp" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ mybuyo-foodlion-mvp"
