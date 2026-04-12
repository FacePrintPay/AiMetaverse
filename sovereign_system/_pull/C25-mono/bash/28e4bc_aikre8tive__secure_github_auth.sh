# REPO: aikre8tive | FILE: secure_github_auth.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash

echo "🔐 Starting Secure GitHub Auth Setup..."
read -sp "Enter your new GitHub PAT (hidden): " token

# Save to .env securely
echo "GITHUB_TOKEN=\"$token\"" > .env
chmod 600 .env
echo "✅ .env created and locked"

# Add to .gitignore if not already there
grep -qxF ".env" .gitignore || echo ".env" >> .gitignore
echo "📜 .env protected via .gitignore"

# Export on login (optional: comment if using `.env` manually)
grep -qxF "source ~/aikre8tive/.env" ~/.bashrc || echo "source ~/aikre8tive/.env" >> ~/.bashrc
grep -qxF "source ~/aikre8tive/.env" ~/.zshrc  || echo "source ~/aikre8tive/.env" >> ~/.zshrc

echo "🔁 Reloading shell environment..."
source ~/.bashrc 2>/dev/null || source ~/.zshrc

echo "🧠 GitHub Token loaded into GITHUB_TOKEN"
echo "💾 You can now use it in scripts via \$GITHUB_TOKEN"
