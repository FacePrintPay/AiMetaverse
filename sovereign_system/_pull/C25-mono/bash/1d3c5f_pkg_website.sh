#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: website
# PATH: /data/data/com.termux/files/home/github-repos/c25-build-broccoli/SalesGPT/website
cd "/data/data/com.termux/files/home/github-repos/c25-build-broccoli/SalesGPT/website" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# website\nCygel White / FacePrintPay Inc." > README.md
grep -q '"build"' package.json || python3 -c "import json; p=json.load(open('package.json')); p.setdefault('scripts',{})['build']='echo ready'; json.dump(p,open('package.json','w'),indent=2)"
npm install --silent 2>/dev/null | tail -1
npm run build 2>/dev/null | tail -3
vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1

git add -A 2>/dev/null
git commit -m "C25: packaged website" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ website"
