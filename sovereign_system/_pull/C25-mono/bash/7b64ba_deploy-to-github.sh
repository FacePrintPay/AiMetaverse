#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
# ⚠️ EDIT THESE:
GITHUB_USERNAME=FacePrintPay 
GITHUB_EMAIL=CyGeL.co@gmail.com
echo "════════════════════════════════════════════════════════════"
echo "  🚀 GITHUB AUTOMATED DEPLOYMENT"
echo "════════════════════════════════════════════════════════════"
echo ""
# Install git if needed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    pkg install -y git
fi
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
REPOS_DIR="$HOME/github-repos"
mkdir -p "$REPOS_DIR"
deploy_repo() {
    local name=$1
    local desc=$2
    echo ""
    echo "Deploying: $name"
    if [ ! -d "$HOME/$name" ]; then
        echo "  Skipping (not found)"
        return
    fi
    local repo="$REPOS_DIR/$name"
    mkdir -p "$repo"
    cd "$repo"
    [ ! -d ".git" ] && git init && git remote add origin "https://github.com/$GITHUB_USERNAME/$name.git"
    rsync -av --exclude='.git' --exclude='node_modules' "$HOME/$name/" "$repo/" 2>/dev/null || cp -r "$HOME/$name/"* "$repo/"
    # Create README
    cat > README.md << EOF
# $name
$desc
## Installation
\`\`\`bash
git clone https://github.com/$GITHUB_USERNAME/$name.git
\`\`\`
Built by CyGeL White | Sovereign AI Empire
EOF
    git add .
    git commit -m "🚀 Deploy $(date '+%Y-%m-%d')" 2>/dev/null || echo "  No changes"
    echo "  ✓ Ready to push"
    echo "  Create repo: https://github.com/new"
    echo "  Then: cd $repo && git push -u origin main"
}
deploy_repo "sovereign-ai-empire-monorepo" "AI orchestration monorepo"
deploy_repo "NightSkyEngine" "3D rendering engine"
deploy_repo "sovereign-parasol" "Insurance platform"
deploy_repo "CodeAssist" "AI-powered IDE"
deploy_repo "cleanbuildfresh" "Build system"
echo ""
echo "✓ Deployment complete!"
echo "All repos in: $REPOS_DIR"
