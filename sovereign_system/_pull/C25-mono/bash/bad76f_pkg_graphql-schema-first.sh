#!/data/data/com.termux/files/usr/bin/bash
# PACKAGE: graphql-schema-first
# PATH: /data/data/com.termux/files/home/repos/stargate-grpc-nosqlbench/driver-http/src/main/resources/activities/graphql-schema-first
cd "/data/data/com.termux/files/home/repos/stargate-grpc-nosqlbench/driver-http/src/main/resources/activities/graphql-schema-first" 2>/dev/null || exit 0

[ ! -f vercel.json ] && echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' > vercel.json
[ ! -f .gitignore ] && printf "node_modules/\ndist/\n.env\n.vercel\n" > .gitignore
[ ! -f .env ] && echo "NODE_ENV=production" > .env
[ ! -f README.md ] && echo "# graphql-schema-first\nCygel White / FacePrintPay Inc." > README.md

git add -A 2>/dev/null
git commit -m "C25: packaged graphql-schema-first" 2>/dev/null | tail -1
git push 2>/dev/null | tail -1
echo "✅ graphql-schema-first"
