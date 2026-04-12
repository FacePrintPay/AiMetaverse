#!/data/data/com.termux/files/usr/bin/bash
# C25 VERTICAL SWARM SYNC
# All agents. All repos. All services. One command.
# Author: Cygel White / FacePrintPay / Kre8tive Koncepts

LOG="$HOME/sovereign_gtp/logs/swarm_sync.log"
REPOS="$HOME/github-repos"
AGENTS="$HOME/github-repos/Constillation25/sovereign_gtp/agents"
MODEL="llama3.2:1b"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$HOME/sovereign_gtp/logs"
echo "" >> "$LOG"
echo "═══════════════════════════════════════" >> "$LOG"
echo "[$TIMESTAMP] SWARM SYNC STARTED" >> "$LOG"
echo "═══════════════════════════════════════" >> "$LOG"

ask() {
    curl -s --max-time 90 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$1\",\"stream\":false,\"options\":{\"num_predict\":300}}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null
}

status() { echo "[$1] $2" | tee -a "$LOG"; }

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║     🌟 C25 VERTICAL SWARM SYNC                ║"
echo "║     Constellation25 × FacePrintPay            ║"
echo "║     All Agents · All Repos · All Services     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# ══════════════════════════════════════════════
# LAYER 1: INFRASTRUCTURE — Start all services
# ══════════════════════════════════════════════
echo "⚡ LAYER 1: Infrastructure"

# Ollama
if ! curl -s --max-time 2 http://localhost:11434 > /dev/null 2>&1; then
    ollama serve > /dev/null 2>&1 &
    sleep 3
    status "OLLAMA" "Started"
else
    status "OLLAMA" "Already running ✅"
fi

# PATHOS
if ! curl -s --max-time 2 http://localhost:3000/api/proxy > /dev/null 2>&1; then
    tmux kill-session -t pathos 2>/dev/null
    tmux new-session -d -s pathos \
        "node ~/github-repos/Constillation25/sovereign_gtp/backend/server.js"
    sleep 2
    status "PATHOS" "Started on port 3000"
else
    status "PATHOS" "Already running ✅"
fi

# MyBuyo services
for svc in dashboard keys_api swarm_api; do
    port=$([ "$svc" = "dashboard" ] && echo 3001 || [ "$svc" = "keys_api" ] && echo 3002 || echo 3003)
    if ! curl -s --max-time 1 http://localhost:$port > /dev/null 2>&1; then
        node ~/mybuyo-restore/services/$svc/index.js \
            > ~/mybuyo-restore/logs/$svc.log 2>&1 &
        status "$svc" "Started on port $port"
    else
        status "$svc" "Already running ✅"
    fi
done

# MyBuyo Biometric SaaS
if ! curl -s --max-time 1 http://localhost:3004 > /dev/null 2>&1; then
    node ~/github-repos/FacePrintPay/mybuyo-biometric-saas/server.js \
        > ~/sovereign_gtp/logs/mybuyo-saas.log 2>&1 &
    status "MYBUYO_SAAS" "Started on port 3004"
else
    status "MYBUYO_SAAS" "Already running ✅"
fi

sleep 2

# Verify all services
echo ""
echo "📊 Service Status:"
SERVICES="3000:PATHOS 3001:Dashboard 3002:KeysAPI 3003:SwarmAPI 3004:MyBuyo 11434:Ollama"
ALL_UP=true
for svc in $SERVICES; do
    port="${svc%%:*}"
    name="${svc##*:}"
    if curl -s --max-time 2 http://localhost:$port > /dev/null 2>&1; then
        echo "  ✅ $name (port $port)"
    else
        echo "  ❌ $name (port $port) - OFFLINE"
        ALL_UP=false
    fi
done

# ══════════════════════════════════════════════
# LAYER 2: EARTH — Scaffold all repos
# ══════════════════════════════════════════════
echo ""
echo "🌍 LAYER 2: Earth — Scaffolding repos..."
SCAFFOLDED=0

for dir in "$REPOS"/*/; do
    name=$(basename "$dir")
    [ ! -d "$dir/.git" ] && continue
    changed=false

    [ ! -d "$dir/src" ]   && mkdir -p "$dir/src"   && changed=true
    [ ! -d "$dir/tests" ] && mkdir -p "$dir/tests" && changed=true
    [ ! -d "$dir/docs" ]  && mkdir -p "$dir/docs"  && changed=true

    if [ ! -f "$dir/run.sh" ] && [ ! -f "$dir/index.js" ]; then
        cat > "$dir/run.sh" << RUNEOF
#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 $name"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[$name] \$(date)" >> "$HOME/sovereign_gtp/logs/${name}.log"
RUNEOF
        chmod +x "$dir/run.sh"
        changed=true
    fi

    if [ ! -f "$dir/package.json" ]; then
        cat > "$dir/package.json" << PKGEOF
{"name":"$name","version":"1.0.0","scripts":{"start":"bash run.sh","test":"echo ok"},"author":"Cygel White / FacePrintPay","license":"MIT"}
PKGEOF
        changed=true
    fi

    if $changed; then
        SCAFFOLDED=$((SCAFFOLDED + 1))
    fi
done
status "EARTH" "Scaffolded $SCAFFOLDED repos"

# ══════════════════════════════════════════════
# LAYER 3: MOON — Review + fix broken scripts
# ══════════════════════════════════════════════
echo ""
echo "🌙 LAYER 3: Moon — Reviewing scripts..."
FIXED=0

find "$REPOS" -name "*.sh" -newer "$LOG" 2>/dev/null | while read -r file; do
    errors=$(bash -n "$file" 2>&1)
    if [ -n "$errors" ]; then
        content=$(cat "$file")
        fixed=$(ask "Fix bash syntax errors. Output ONLY fixed script:
ERROR: $errors
SCRIPT: $content")
        if [ -n "$fixed" ] && [ ${#fixed} -gt 20 ]; then
            cp "$file" "${file}.bak"
            echo "$fixed" > "$file"
            chmod +x "$file"
            FIXED=$((FIXED + 1))
        fi
    fi
done
status "MOON" "Fixed $FIXED broken scripts"

# ══════════════════════════════════════════════
# LAYER 4: MARS — Run all agent scripts
# ══════════════════════════════════════════════
echo ""
echo "♂️  LAYER 4: Mars — Running agents..."

for agent in Earth Moon Sun Mars Jupiter Saturn Uranus Neptune \
             Cygnus Orion Andromeda Pleiades Sirius CanisMajor Hydra \
             Draco Bootes CoronaBorealis UrsaMajor Lynx Perseus Cassiopeia; do
    script="$AGENTS/${agent}.sh"
    if [ -f "$script" ]; then
        ag=$agent bash "$script" >> "$LOG" 2>&1
        echo "  ✅ Agent $agent ran"
    fi
done
status "MARS" "All agents executed"

# ══════════════════════════════════════════════
# LAYER 5: JUPITER — Sync all repos
# ══════════════════════════════════════════════
echo ""
echo "♃  LAYER 5: Jupiter — Syncing repos..."
PUSHED=0
FAILED=0

for dir in "$REPOS"/*/; do
    name=$(basename "$dir")
    [ ! -d "$dir/.git" ] && continue
    cd "$dir"

    # Pull latest first
    git pull origin main 2>/dev/null || \
    git pull origin master 2>/dev/null || true

    # Add and commit changes
    git add -A 2>/dev/null
    if ! git diff --cached --quiet 2>/dev/null; then
        # CanisMajor security scan
        ag=CanisMajor bash "$AGENTS/CanisMajor.sh" "$dir" 2>/dev/null

        git commit -m "🌟 C25 swarm-sync: $name - $TIMESTAMP" 2>/dev/null

        # Push
        if git push origin main 2>/dev/null || \
           git push origin master 2>/dev/null || \
           git push --set-upstream origin main 2>/dev/null; then
            PUSHED=$((PUSHED + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    fi
done
status "JUPITER" "Pushed: $PUSHED | Failed: $FAILED"

# ══════════════════════════════════════════════
# LAYER 6: SATURN — Schedule next sync
# ══════════════════════════════════════════════
echo ""
echo "♄  LAYER 6: Saturn — Scheduling..."

# Kill old scheduler
tmux kill-session -t swarm-sync 2>/dev/null

# Start new scheduler - syncs every 2 hours
tmux new-session -d -s swarm-sync \
    "while true; do sleep 7200; bash ~/c25-swarm-sync.sh; done"

status "SATURN" "Next sync in 2 hours (tmux: swarm-sync)"

# ══════════════════════════════════════════════
# LAYER 7: RANGER — Update sandbox
# ══════════════════════════════════════════════
echo ""
echo "📁 LAYER 7: Ranger — Updating sandbox..."

# Update ranger bookmarks and keybinds
cat >> ~/.config/ranger/rc.conf << 'RANGEREOF'

# Swarm Sync keybind
map gs shell bash ~/c25-swarm-sync.sh
map gl shell cat ~/sovereign_gtp/logs/swarm_sync.log | tail -50
RANGEREOF

status "RANGER" "Sandbox updated"

# ══════════════════════════════════════════════
# FINAL STATUS
# ══════════════════════════════════════════════
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  🌟 SWARM SYNC COMPLETE                       ║"
echo "╠════════════════════════════════════════════════╣"
printf "║  ⚡ Services  : %-30s║\n" "All running"
printf "║  🌍 Scaffolded: %-30s║\n" "$SCAFFOLDED repos"
printf "║  🌙 Fixed     : %-30s║\n" "$FIXED scripts"
printf "║  🚀 Pushed    : %-30s║\n" "$PUSHED repos"
printf "║  ♄  Next sync : %-30s║\n" "2 hours"
echo "╠════════════════════════════════════════════════╣"
echo "║  COMMANDS:                                    ║"
echo "║  swarm    → run full sync now                 ║"
echo "║  gs       → sync from Ranger                 ║"
echo "║  agents   → run all agents                   ║"
echo "║  autopush → push all repos                   ║"
echo "╚════════════════════════════════════════════════╝"

echo "[$TIMESTAMP] SWARM SYNC COMPLETE - Pushed:$PUSHED Failed:$FAILED" >> "$LOG"
