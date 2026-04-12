#!/bin/bash
echo "🚀 Deploying mybuyo..."
# Install dependencies
npm install
# Build
npm run build
# Deploy to Vercel
vercel --prod --yes
echo "✅ mybuyo deployed!"
