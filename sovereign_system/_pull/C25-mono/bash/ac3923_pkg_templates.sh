#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: templates
# PATH: /data/data/com.termux/files/home/repos/data-api/helm/jsonapi/templates
cd "/data/data/com.termux/files/home/repos/data-api/helm/jsonapi/templates" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# templates\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged templates" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ templates"
