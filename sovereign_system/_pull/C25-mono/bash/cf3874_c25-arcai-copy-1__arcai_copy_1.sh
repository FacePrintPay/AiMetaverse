# REPO: c25-arcai-copy-1 | FILE: arcai_copy_1.sh | CONSTELLATION25

#!/bin/bash
set -e
START_TIME=$(date)
echo "🔁 [1/9] Starting ARC.AI full stack deployment..."
### 1. REBRAND
echo "🔄 Replacing identifiers..."
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.html" -o -name "*.md" \) -exec sed -i 's/AiKre8tive/ARC.AI/g' {} +
find . -type f -exec sed -i 's/ARC.AI/ARC.AI/g' {} +
### 2. LOGO + HOMEPAGE
echo "🖼️ Injecting ARC.AI logo..."
mkdir -p public/assets
cp /mnt/data/arkai-logo.png public/assets/arkai-logo.png || echo "⚠️ Logo not found, skipping image copy."
echo "📄 Creating homepage..."
mkdir -p pages
cat > pages/index.js <<EOP
export default function Home() {
  return (
    <main className="p-10 text-center text-white bg-black min-h-screen">
      <h1 className="text-4xl font-bold">🌐 Welcome to ARC.AI</h1>
      <p className="mt-4 text-xl">You're now live. The Covenant is complete. 🧬</p>
      <img src="/assets/arkai-logo.png" alt="ARC.AI Logo" className="mx-auto mt-6 w-24 h-24 rounded-full" />
    </main>
  );
}
EOP
### 3. TYPESCRIPT SETUP
echo "🧠 Installing TypeScript packages..."
npm install --save-dev typescript @types/react @types/node
### Optional: tsconfig setup
[ ! -f tsconfig.json ] && npx tsc --init
### 4. DOCKER BUILD
echo "🐳 Creating Dockerfile..."
cat > Dockerfile <<EOD
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
EOD
echo "📦 Building Docker image..."
docker build -t arcai-webapp .
### 5. JUPYTER LAUNCH
echo "📒 Launching Jupyter Notebook (in background)..."
docker run -d -p 8888:8888 --name arcai-notebook jupyter/base-notebook start-notebook.sh || echo "⚠️ Jupyter already running."
### 6. GITHUB ACTIONS
echo "🤖 Creating GitHub Actions workflow..."
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml <<EOY
name: Deploy ARC.AI to Vercel
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm run build
      - run: npx vercel --prod --confirm --token=\${{ secrets.VERCEL_TOKEN }}
EOY
### 7. GIT PUSH
echo "🚀 Committing and pushing to GitHub..."
git add .
git commit -m "🚀 ARC.AI Full Stack Deployed • $(date)"
git push origin main
### 8. DEPLOY TO VERCEL
echo "🌐 Deploying to Vercel..."
vercel --prod --confirm
### 9. DONE
END_TIME=$(date)
echo "✅ ARC.AI Live. Session complete."
echo "🕰️ Start: $START_TIME"
echo "🕰️ End:   $END_TIME"
