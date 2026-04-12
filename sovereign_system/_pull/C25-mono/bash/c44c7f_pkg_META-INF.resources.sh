#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: META-INF.resources
# PATH: /data/data/com.termux/files/home/repos/dynamoDB-adapter/src/main/resources/META-INF.resources
cd "/data/data/com.termux/files/home/repos/dynamoDB-adapter/src/main/resources/META-INF.resources" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# META-INF.resources\nCygel White / FacePrintPay Inc." > README.md
vercel --yes --prod 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged META-INF.resources" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ META-INF.resources"
