#!/bin/bash
# SovereignDeck Deployment: GitHub + Cloudflare Pages + GoDaddy DNS
# by #MrGGTP | SovereignGTP

set -e

# === PROJECT CONFIG ===
PROJECT_NAME="sovereign-deck"
GIT_REPO="https://github.com/Kre8tive-Konceptz/Sovereign.git"
GIT_BRANCH="main"
GIT_USER="Cygel White"
GIT_EMAIL="cygel@sovereigngtp.com"
CLOUDFLARE_DIR="dist"
DOMAIN="sovereigndeck.ai"
CLOUDFLARE_YAML_FILE=".cloudflare/pages.yml"

# === STEP 1: Git Init & Push ===
echo "🚀 Initializing SovereignDeck Git Repo"
cd ~/$PROJECT_NAME
git init
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git branch -M $GIT_BRANCH
git add .
git commit -m "Initial SovereignDeck v1 push"
git remote add origin $GIT_REPO
git push -u origin $GIT_BRANCH

# === STEP 2: Cloudflare Pages Config ===
echo "📄 Generating Cloudflare Pages YAML..."
mkdir -p .cloudflare
cat > $CLOUDFLARE_YAML_FILE <<CFYAML
name: sovereign-deck-ui
build:
  command: npm run build
  directory: $CLOUDFLARE_DIR
  environment:
    NODE_VERSION: 20
    VITE_ENV: production
deployment:
  production_branch: $GIT_BRANCH
  routes:
    - https://$DOMAIN
CFYAML

# === STEP 3: GoDaddy DNS (Manual Step Reminder) ===
echo "🔗 Setting up GoDaddy DNS for $DOMAIN"
echo "⚠️  Go to your GoDaddy dashboard > DNS Management"
echo "➡️  Add A Record:"
echo "   - Type: A"
echo "   - Name: @"
echo "   - Value: 192.0.2.1 (Use Cloudflare IPs)"
echo "➡️  Add TXT for verification if prompted by Cloudflare"
echo "   - Type: TXT"
echo "   - Name: @"
echo "   - Value: cloudflare-verification=XXXXXXX"

echo "✅ SovereignDeck now staged for deployment via GitHub + Cloudflare + GoDaddy"
echo "💥 Push live on Cloudflare Pages once domain DNS resolves."
