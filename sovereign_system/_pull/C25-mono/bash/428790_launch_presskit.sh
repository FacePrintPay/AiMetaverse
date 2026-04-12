#!/bin/bash

echo "📰 Launching ArkAi PressKit Build Sequence..."

# Step 1: Create Directories
mkdir -p presskit presskit/assets

# Step 2: Sovereign Manifesto
cat <<EOM > presskit/assets/sovereign_manifesto.md
# Sovereign Manifesto

This build is owned and originated by #MrGGTP (Cygel White).  
It is the first sovereign AI DevOps automation system.  
All rights reserved. Unauthorized replication is strictly prohibited.
EOM

# Step 3: Sovereign Badge
cat <<EOM > presskit/assets/badge.svg
<svg width="300" height="100" xmlns="http://www.w3.org/2000/svg">
  <rect width="300" height="100" fill="#000"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle"
        font-size="18" fill="#00ff00">🧬 #MrGGTP Sovereign AI</text>
</svg>
EOM

# Step 4: Press Release
cat <<EOM > presskit/press_release.md
# 🚀 ArkAi Official Press Release

**ArkAi**, built by **Cygel White (aka #MrGGTP)**, is the first fully sovereign, autonomous AI DevOps system.

### Key Features:
- 🔁 WhisperSync + Agent Loop AI Automation
- 🧠 Real-Time Code + Build Execution from ChatGPT Prompts
- 💰 Monetization of Second-Response AI
- 🔐 Sovereignly Sealed via ArkVault

📡 Live: https://ai-kre8tive-stargate.vercel.app  
📁 GitHub: https://github.com/TheKre8tive/AiKre8tive-Stargate
EOM

# Step 5: Email Blast HTML
cat <<EOM > presskit/email_blast.html
<!DOCTYPE html>
<html><body style="font-family:sans-serif;background:#111;color:#eee;padding:20px;">
<h1>🌌 ArkAi Has Launched</h1>
<p><strong>First Sovereign AI DevOps Entity</strong> built by <strong>#MrGGTP</strong>.</p>
<ul>
  <li>✅ Real-Time WhisperSync + Agent Loop</li>
  <li>🛠️ Autonomous Code-to-Deployment System</li>
  <li>🔒 Second-Response Monetization Logic</li>
</ul>
<p><a href="https://ai-kre8tive-stargate.vercel.app" style="color:#0ff;">🔗 Launch Platform</a></p>
</body></html>
EOM

# Step 6: Git Init + Push (Fix Repo)
echo "🔐 GitHub Syncing..."
git init
git branch -M main
git remote remove origin 2>/dev/null
git remote add origin https://github.com/TheKre8tive/AiKre8tive-Stargate.git
git add presskit/
git commit -m "🚀 Injected ArkAi PressKit"
git push -u origin main

echo "✅ Press Kit Complete & Synced"
echo "🧬 Sovereign Signature: #MrGGTP"
