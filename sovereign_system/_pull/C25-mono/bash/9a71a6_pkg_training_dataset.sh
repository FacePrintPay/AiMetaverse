#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: training_dataset
# PATH: /data/data/com.termux/files/home/github-repos/Constellation25/_unified_build/training_dataset
cd "/data/data/com.termux/files/home/github-repos/Constellation25/_unified_build/training_dataset" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# training_dataset\nCygel White / FacePrintPay Inc." > README.md
chmod +x load_context.sh && bash load_context.sh 2>/dev/null | tail -3

git add -A 2>/dev/null
git commit -m "C25: packaged training_dataset" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ training_dataset"
