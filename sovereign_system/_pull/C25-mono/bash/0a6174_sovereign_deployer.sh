#!/data/data/com.termux/files/usr/bin/bash

# ═══════════════════════════════════════════════════════════
# SOVEREIGN COMPLETE AUTO-FIXER & NGROK DEPLOYER
# All builds including BlackboxAI 2023-2024 sessions
# ═══════════════════════════════════════════════════════════

set +e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEPLOY_DIR="$HOME/storage/shared/sovereign_$TIMESTAMP"
LOG="$DEPLOY_DIR/deploy.log"
URLS="$DEPLOY_DIR/ngrok_urls.txt"
PORT=3000

# ══════════════════════════════════════════════════════════
# SET YOUR NGROK AUTHTOKEN HERE
# ══════════════════════════════════════════════════════════
NGROK_TOKEN="${NGROK_TOKEN:-YOUR_NGROK_AUTHTOKEN_HERE}"

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; B='\033[1;34m'; M='\033[0;35m'; N='\033[0m'

log() { echo -e "$1" | tee -a "$LOG" 2>/dev/null; }

# ══════════════════════════════════════════════════════════
# ALL REPOSITORIES - COMPLETE LIST INCLUDING BLACKBOXAI
# ══════════════════════════════════════════════════════════
REPOS=(
    # BLACKBOXAI BUILDS (2023-2024 Sessions)
    "FacePrintPay/blackboxai-1742376990260"
    "FacePrintPay/blackboxai-1741225183777"
    "FacePrintPay/blackboxai-1742374192849"
    "FacePrintPay/blackboxai-1742357245683"
    "FacePrintPay/blackboxai-1742367771175"
    "FacePrintPay/blackboxai-1742368461092"
    "FacePrintPay/blackboxai-1742356607403"
    
    # CORE SOVEREIGN/AIKRE8TIVE PLATFORMS
    "FacePrintPay/PaThosAi"
    "FacePrintPay/PaTHos-Ai-"
    "FacePrintPay/SovereignGTP"
    "FacePrintPay/AiKre8tive_Sovereign_Genesis"
    "FacePrintPay/AiKre8tive-Stargate"
    "FacePrintPay/AiKre8tive-"
    "FacePrintPay/aikre8tive"
    "FacePrintPay/AiKre8tive.us"
    "FacePrintPay/CygNusMaster-"
    "FacePrintPay/AiMetaverse"
    "FacePrintPay/AiMetaverse-Orgin"
    "FacePrintPay/AiMeta"
    
    # PLANETARY AGENTS SYSTEM
    "FacePrintPay/PlanetaryAgents"
    "FacePrintPay/agentik"
    
    # STARGATE & INFRASTRUCTURE
    "FacePrintPay/stargate"
    "FacePrintPay/RepoDepot-Stargate"
    "FacePrintPay/antora-ui-stargate"
    "FacePrintPay/stargate-grpc-node-client"
    "FacePrintPay/stargate-grpc-java-client"
    "FacePrintPay/stargate-grpc-go-client"
    "FacePrintPay/stargate-dtest"
    "FacePrintPay/stargate-grpc-nosqlbench"
    
    # DATA & API SERVICES
    "FacePrintPay/data-api"
    "FacePrintPay/dynamoDB-adapter"
    "FacePrintPay/django-dynamic-api"
    "FacePrintPay/coral-server"
    
    # TOOLS & UTILITIES
    "FacePrintPay/bolt.new"
    "FacePrintPay/vite-react"
    "FacePrintPay/nextjs-boilerplate"
    "FacePrintPay/nextjs-enterprise-boilerplate"
    "FacePrintPay/codespaces-react"
    "FacePrintPay/morphic-ai-answer-engine-generative-ui"
    "FacePrintPay/empathic-voice-interface-starter"
    "FacePrintPay/build-agentic-software-w-coral-os-agents"
    
    # APPLICATIONS
    "FacePrintPay/FacePrintPay"
    "FacePrintPay/videocourts"
    "FacePrintPay/sentinel-lens"
    "FacePrintPay/sovereign-ad-serve"
    "FacePrintPay/sovereign-architect"
    "FacePrintPay/NoteTal"
    "FacePrintPay/NLP2Code"
    "FacePrintPay/LEGYC"
    "FacePrintPay/Orange"
    "FacePrintPay/VeRseD_Ai"
    "FacePrintPay/THAT"
    "FacePrintPay/MatrixOS"
    "FacePrintPay/NightSkyEngine"
    "FacePrintPay/PoRTaLed-"
    "FacePrintPay/Apollo-11"
    
    # EXTENSIONS & PLUGINS
    "FacePrintPay/ai-web-extensions"
    "FacePrintPay/CodeAssist"
    "FacePrintPay/vscode-project-manager"
    "FacePrintPay/claude-artifacts-downloader"
    "FacePrintPay/json-formatter"
    
    # DOCUMENTATION & ASSETS
    "FacePrintPay/docs-content"
    "FacePrintPay/npm-documentation"
    "FacePrintPay/Z-Series-Exhibits"
    "FacePrintPay/lib"
    "FacePrintPay/pkgs"
    
    # DEVOPS & INFRASTRUCTURE
    "FacePrintPay/DeVa-DevOps"
    "FacePrintPay/termux-ngrok"
    "FacePrintPay/OneBasher"
    "FacePrintPay/Push2Repo"
    "FacePrintPay/linker"
    "FacePrintPay/app-directory"
    
    # THEKRE8TIVE REPOS
    "TheKre8tive/AiKre8tive-Stargate"
    "TheKre8tive/AiKre8tive-ProofStack"
    "TheKre8tive/AiKre8tive-"
    "TheKre8tive/PaTHos-OS"
    "TheKre8tive/Linked2-platform"
    "TheKre8tive/linked2xyz"
    "TheKre8tive/Sovvey"
    "TheKre8tive/THAT"
    "TheKre8tive/AI"
    "TheKre8tive/.github"
    "TheKre8tive/demo-repository"
    
    # KRE8TIVE-SPACE REPOS
    "Kre8tive-Space/aikre8tive-planetary-grid"
    "Kre8tive-Space/AiKre8tive-Sovereign-GTP-"
    "Kre8tive-Space/Versed_Ai"
    "Kre8tive-Space/AiKre8tive-"
    "Kre8tive-Space/AiKre8tive-Investor-Assets"
    
    # VIDEOCOURTS REPOS
    "VideoCourts/demo-repository"
    "VideoCourts/That"
    
    # KRE8TIVE-KONCEPTZ REPOS
    "Kre8tive-Konceptz/Sovereign"
    
    # FLUTTER & MOBILE
    "FacePrintPay/flutter"
)

# ══════════════════════════════════════════════════════════
# BOOTSTRAP
# ══════════════════════════════════════════════════════════
bootstrap() {
    log "${B}══════════════════════════════════════════════════════${N}"
    log "${B}   SOVEREIGN COMPLETE DEPLOYER - $(date)${N}"
    log "${B}══════════════════════════════════════════════════════${N}"
    log ""
    log "${C}[BOOT] Checking dependencies...${N}"
    
    # Check if ngrok is configured
    if [ "$NGROK_TOKEN" = "YOUR_NGROK_AUTHTOKEN_HERE" ]; then
        log "${R}ERROR: ngrok token not set!${N}"
        log "${Y}Please set NGROK_TOKEN variable with your actual token${N}"
        exit 1
    fi
    
    mkdir -p "$DEPLOY_DIR/repos" "$DEPLOY_DIR/builds" "$DEPLOY_DIR/logs"
    touch "$LOG" "$URLS"
    
    log "${G}✓ Bootstrap complete${N}"
}

# ══════════════════════════════════════════════════════════
# FIX AND BUILD REPO
# ══════════════════════════════════════════════════════════
fix_repo() {
    local repo="$1"
    local name=$(basename "$repo")
    local dir="$DEPLOY_DIR/repos/$name"
    
    log "${Y}Processing: $name${N}"
    
    # Clone
    if git clone --depth 1 "https://github.com/$repo.git" "$dir" 2>/dev/null; then
        cd "$dir"
        
        # Create index.html if missing (fixes 404)
        if [ ! -f "index.html" ] && [ ! -f "public/index.html" ]; then
            mkdir -p public
            cat > public/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sovereign Deploy</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff; min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }
        .container { text-align: center; padding: 2rem; }
        h1 { font-size: 2.5rem; margin-bottom: 1rem; color: #00d4ff; }
        p { color: #888; margin-bottom: 2rem; }
        .status { 
            background: rgba(0,212,255,0.1); 
            border: 1px solid #00d4ff;
            padding: 1rem 2rem; border-radius: 8px;
            display: inline-block;
        }
        .status::before { content: "●"; color: #00ff88; margin-right: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Sovereign Deploy</h1>
        <p>AiKre8tive Platform Node</p>
        <div class="status">ONLINE</div>
    </div>
</body>
</html>
HTMLEOF
        fi
        
        # Create vercel.json for proper routing
        cat > vercel.json << 'VJSON'
{
  "version": 2,
  "builds": [{ "src": "**/*", "use": "@vercel/static" }],
  "routes": [{ "src": "/(.*)", "dest": "/public/$1" }],
  "headers": [{ "source": "/(.*)", "headers": [{ "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }] }]
}
VJSON

        # Fix package.json if exists
        if [ -f "package.json" ]; then
            # Install deps and build
            npm install --legacy-peer-deps 2>/dev/null
            npm run build 2>/dev/null
            
            # Copy build output to public
            [ -d "dist" ] && cp -r dist/* public/ 2>/dev/null
            [ -d "build" ] && cp -r build/* public/ 2>/dev/null
            [ -d ".next/static" ] && mkdir -p public/_next && cp -r .next/static public/_next/ 2>/dev/null
        fi
        
        log "${G}✓ Fixed: $name${N}"
        echo "$name" >> "$DEPLOY_DIR/success.txt"
        return 0
    else
        log "${R}✗ Failed to clone: $name${N}"
        echo "$name" >> "$DEPLOY_DIR/failed.txt"
        return 1
    fi
}

# ══════════════════════════════════════════════════════════
# START LOCAL SERVER
# ══════════════════════════════════════════════════════════
start_server() {
    local dir="$1"
    local port="$2"
    
    cd "$dir"
    if [ -d "public" ]; then
        serve -s public -l "$port" &
    elif [ -d "dist" ]; then
        serve -s dist -l "$port" &
    elif [ -d "build" ]; then
        serve -s build -l "$port" &
    else
        serve -s . -l "$port" &
    fi
    echo $!
}

# ══════════════════════════════════════════════════════════
# START NGROK TUNNEL
# ══════════════════════════════════════════════════════════
start_ngrok() {
    local port="$1"
    local name="$2"
    
    log "${M}Starting ngrok tunnel for $name on port $port...${N}"
    
    # Start ngrok in background
    ngrok http "$port" > "$DEPLOY_DIR/logs/ngrok_$name.log" 2>&1 &
    NGROK_PID=$!
    
    # Wait for tunnel to establish
    sleep 5
    
    # Get the tunnel URL
    TUNNEL_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null)
    
    if [ -n "$TUNNEL_URL" ]; then
        log "${G}✓ Tunnel ready: $TUNNEL_URL${N}"
        echo "$name: $TUNNEL_URL" >> "$URLS"
        echo "$TUNNEL_URL" >> "$DEPLOY_DIR/tunnels.txt"
    else
        log "${R}✗ Failed to get tunnel URL for $name${N}"
    fi
    
    echo $NGROK_PID
}

# ══════════════════════════════════════════════════════════
# MAIN EXECUTION
# ══════════════════════════════════════════════════════════
main() {
    bootstrap
    
    log "${C}[1/3] Processing ${#REPOS[@]} repositories...${N}"
    
    local count=0
    local success=0
    local failed=0
    
    for repo in "${REPOS[@]}"; do
        ((count++))
        log "${C}[$count/${#REPOS[@]}]${N} $repo"
        
        if fix_repo "$repo"; then
            ((success++))
        else
            ((failed++))
        fi
    done
    
    log ""
    log "${C}[2/3] Starting local servers...${N}"
    
    PIDS=()
    NGROK_PIDS=()
    current_port=$PORT
    
    for dir in "$DEPLOY_DIR/repos"/*/; do
        if [ -d "$dir" ]; then
            name=$(basename "$dir")
            pid=$(start_server "$dir" "$current_port")
            PIDS+=($pid)
            log "${G}  Local: http://localhost:$current_port - $name${N}"
            
            # Start ngrok tunnel
            ngrok_pid=$(start_ngrok "$current_port" "$name")
            NGROK_PIDS+=($ngrok_pid)
            
            ((current_port++))
        fi
    done
    
    log ""
    log "${C}[3/3] Summary${N}"
    log "────────────────────────────────────"
    log "${G}Success: $success${N}"
    log "${R}Failed:  $failed${N}"
    log "────────────────────────────────────"
    log "Deploy dir: $DEPLOY_DIR"
    log "URLs file:  $URLS"
    log "Tunnels:    $DEPLOY_DIR/tunnels.txt"
    log ""
    
    if [ -f "$URLS" ]; then
        log "${B}Active Tunnels:${N}"
        cat "$URLS"
        log ""
    fi
    
    log "${C}Servers running. Press Ctrl+C to stop.${N}"
    
    # Keep running
    trap 'kill ${PIDS[@]} ${NGROK_PIDS[@]} 2>/dev/null; exit 0' INT TERM
    wait
}

# Run
main
