#!/usr/bin/env bash
echo "🚀 Deploying Sovereign AI..."
if command -v vercel &>/dev/null; then
  vercel --prod
elif command -v netlify &>/dev/null; then
  netlify deploy --prod
else
  echo "⚠ Install vercel/netlify CLI or manually deploy contents of this folder"
fi
