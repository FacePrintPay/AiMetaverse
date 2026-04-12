#!/data/data/com.termux/files/usr/bin/bash
# Master Fix Script - Sets up EVERYTHING
echo "🚀 SOVEREIGN AI EMPIRE - MASTER SETUP"
echo "======================================"
echo ""
# Update packages
echo "📦 Updating packages..."
pkg update -y && pkg upgrade -y
# Install essentials
echo "⚙️ Installing essentials..."
pkg install -y git gh nodejs python openssh rsync termux-api
# Setup storage
echo "💾 Setting up storage..."
if [ -d "$HOME/storage" ]; then
    rm -rf "$HOME/storage"
fi
termux-setup-storage <<< "y"
# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p ~/kre8tive-empire/{repos,projects,artifacts,docs,builds,deployments}
# Install Vercel CLI
echo "☁️ Installing Vercel CLI..."
npm install -g vercel
# Setup GitHub CLI
echo "🔗 Setting up GitHub CLI..."
if ! gh auth status &>/dev/null; then
    echo "Please login to GitHub:"
    gh auth login
fi
# Create quick aliases
echo "⚡ Creating aliases..."
cat >> ~/.bashrc << 'ALIASES'
# Quick Commands
alias empire='cd ~/kre8tive-empire'
alias repos='cd ~/kre8tive-empire/repos'
alias deploy='vercel --prod'
alias constellation='bash ~/constellation.sh'
ALIASES
# Clone your repos
echo "📥 Cloning repositories..."
cd ~/kre8tive-empire/repos
gh repo list FacePrintPay --limit 10 --json name -q '.[].name' | head -5 | while read repo; do
    if [ ! -d "$repo" ]; then
        gh repo clone "FacePrintPay/$repo"
    fi
done
# Setup Constellation script
cat > ~/constellation.sh << 'CONST'
#!/data/data/com.termux/files/usr/bin/bash
clear
source ~/.bashrc
CONST
chmod +x ~/constellation.sh
echo ""
echo "✅ SETUP COMPLETE!"
echo ""
echo "🎯 Quick Commands:"
echo "  empire      - Go to main directory"
echo "  repos       - Go to repos"
echo "  deploy      - Deploy current folder to Vercel"
echo "  constellation - Restart agent interface"
echo ""
echo "📱 Close and reopen Termux to see Constellation 25!"
