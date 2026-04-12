#!/bin/bash
# ============================================
# 🚀 SOVEREIGN VIEWER AUTO-DEPLOY (FIXED)
# ============================================

set -e

echo "🧬 [CoMandR] Sovereign Viewer Deployment Initiated..."
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Change to the directory with HTML files
HTML_DIR="$HOME/storage/shared"
cd "$HTML_DIR" || { echo "❌ Directory $HTML_DIR not found"; exit 1; }

# Create logs directory
mkdir -p logs
LOG_FILE="logs/deploy_$DATE.log"

function log() {
  echo "[$(date +"%H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

# 1️⃣ Pre-flight Checks
log "Validating environment..."
command -v git >/dev/null || { log "Git not installed!"; exit 1; }
command -v npx >/dev/null || { log "NPM not installed!"; exit 1; }

# 2️⃣ Validate HTML files exist
log "Checking for HTML files..."
if [[ -f "index_full_dashboard.html" ]]; then
    log "✅ index_full_dashboard.html found"
else
    log "❌ index_full_dashboard.html not found"
    exit 1
fi

# 3️⃣ Local Test (OPTIONAL - comment out if not needed)
log "Running local verification..."
python3 -m http.server 8080 >/dev/null 2>&1 &
SERVER_PID=$!
sleep 3
curl -s http://localhost:8080/index_full_dashboard.html | grep -q "<html" && log "✅ Local server OK" || log "⚠️ HTML validation failed"
kill $SERVER_PID 2>/dev/null

# 4️⃣ Create minimal vercel.json (NO BUILD NEEDED)
log "Creating vercel.json..."
cat > vercel.json << 'EOF'
{
  "version": 2,
  "routes": [
    {"src": "/", "dest": "/index_full_dashboard.html"},
    {"src": "/cards", "dest": "/hero_cards_dashboard.html"}
  ]
}
EOF

# 5️⃣ Deploy to Vercel (SKIP NPM BUILD - STATIC HTML)
log "Deploying to Vercel..."
npx vercel --prod --yes | tee -a "$LOG_FILE"

# 6️⃣ Git backup (if git repo exists)
if [[ -d .git ]]; then
    log "Committing to Git..."
    git add .
    git commit -m "Auto-deploy $DATE" || log "Nothing to commit"
    
    if git remote | grep -q origin; then
        log "Pushing to GitHub..."
        git push origin main || log "⚠️ Push failed"
    fi
else
    log "⚠️ Not a git repo, skipping git operations"
fi

log "🎯 Deployment Complete!"
log "🪞 Total Recall | Total Deploy | Total Victory"
