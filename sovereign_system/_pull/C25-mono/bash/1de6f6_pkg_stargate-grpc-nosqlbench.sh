#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: stargate-grpc-nosqlbench
# PATH: /data/data/com.termux/files/home/repos/stargate-grpc-nosqlbench
cd "/data/data/com.termux/files/home/repos/stargate-grpc-nosqlbench" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# stargate-grpc-nosqlbench\nCygel White / FacePrintPay Inc." > README.md
echo "Docker: stargate-grpc-nosqlbench ready"

git add -A 2>/dev/null
git commit -m "C25: packaged stargate-grpc-nosqlbench" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ stargate-grpc-nosqlbench"
