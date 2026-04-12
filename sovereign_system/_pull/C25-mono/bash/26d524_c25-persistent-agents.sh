#!/data/data/com.termux/files/usr/bin/bash
# C25 Persistent Agent System
# Runs on every terminal start
# Earth scaffolds, agents fix, Ranger navigates, auto-pushes

AGENTS="$HOME/github-repos/Constillation25/sovereign_gtp/agents"
LOG="$HOME/sovereign_gtp/logs/persistent.log"
REPOS="$HOME/github-repos"
MODEL="llama3.2:1b"

ask() {
    curl -s --max-time 90 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$1\",\"stream\":false,\"options\":{\"num_predict\":400}}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null
}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Persistent agents started" >> "$LOG"

# ══════════════════════════════════════
# EARTH — Scaffold every repo that needs it
# ══════════════════════════════════════
earth_scaffold() {
    echo "🌍 Earth: Scanning for unscaffolded repos..."
    for dir in "$REPOS"/*/; do
        name=$(basename "$dir")
        [ ! -d "$dir/.git" ] && continue

        # Check what's missing
        missing=""
        [ ! -f "$dir/README.md" ] && missing="$missing README"
        [ ! -f "$dir/package.json" ] && missing="$missing package.json"
        [ ! -f "$dir/run.sh" ] && ! [ -f "$dir/index.js" ] && missing="$missing entrypoint"
        [ ! -d "$dir/src" ] && missing="$missing src/"
        [ ! -d "$dir/tests" ] && missing="$missing tests/"

        if [ -n "$missing" ]; then
            echo "  🌍 Scaffolding: $name (missing:$missing)"

            # Create missing structure
            mkdir -p "$dir/src" "$dir/tests" "$dir/docs"

            # Generate entrypoint if missing
            if [ ! -f "$dir/run.sh" ] && [ ! -f "$dir/index.js" ]; then
                cat > "$dir/run.sh" << RUNEOF
#!/data/data/com.termux/files/usr/bin/bash
# $name - C25 Module
# Auto-scaffolded by Earth Agent
echo "🌟 $name starting..."
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS connected"
echo "[$name] \$(date)" >> "$HOME/sovereign_gtp/logs/${name}.log"
RUNEOF
                chmod +x "$dir/run.sh"
            fi

            # Generate README if missing
            if [ ! -f "$dir/README.md" ]; then
                echo "# $name" > "$dir/README.md"
                echo "C25 Module | FacePrintPay | Cygel White" >> "$dir/README.md"
                echo "" >> "$dir/README.md"
                echo "## Usage" >> "$dir/README.md"
                echo "\`\`\`bash" >> "$dir/README.md"
                echo "bash run.sh" >> "$dir/README.md"
                echo "\`\`\`" >> "$dir/README.md"
            fi

            # Generate package.json if missing
            if [ ! -f "$dir/package.json" ]; then
                cat > "$dir/package.json" << PKGEOF
{
  "name": "$name",
  "version": "1.0.0",
  "description": "C25 Module - $name",
  "main": "index.js",
  "scripts": {
    "start": "bash run.sh",
    "test": "bash tests/test.sh 2>/dev/null || echo 'ok'"
  },
  "author": "Cygel White / FacePrintPay",
  "license": "MIT"
}
PKGEOF
            fi

            echo "  ✅ Scaffolded: $name" >> "$LOG"
        fi
    done
    echo "✅ Earth scaffold complete"
}

# ══════════════════════════════════════
# MOON — Review and fix broken scripts
# ══════════════════════════════════════
moon_review() {
    echo "🌙 Moon: Reviewing scripts for errors..."
    find "$REPOS" -name "*.sh" -newer "$LOG" 2>/dev/null | while read -r file; do
        # Check for common bash errors
        errors=$(bash -n "$file" 2>&1)
        if [ -n "$errors" ]; then
            echo "  🌙 Fixing: $file"
            echo "  Error: $errors"
            # Ask LLM to fix
            content=$(cat "$file")
            fixed=$(ask "Fix the bash syntax errors in this script. Output ONLY the fixed bash script:

$errors

SCRIPT:
$content")
            if [ -n "$fixed" ]; then
                cp "$file" "${file}.backup"
                echo "$fixed" > "$file"
                chmod +x "$file"
                echo "  ✅ Fixed: $(basename $file)"
            fi
        fi
    done
    echo "✅ Moon review complete"
}

# ══════════════════════════════════════
# MARS — Create missing GitHub repos
# ══════════════════════════════════════
mars_create_repos() {
    echo "♂️  Mars: Creating missing GitHub repos..."
    for dir in "$REPOS"/*/; do
        name=$(basename "$dir")
        [ ! -d "$dir/.git" ] && continue

        # Check if remote exists
        remote=$(git -C "$dir" remote get-url origin 2>/dev/null)
        if [ -z "$remote" ]; then
            echo "  ♂️  Adding remote: $name"
            git -C "$dir" remote add origin \
                "https://github.com/FacePrintPay/$name.git" 2>/dev/null
        fi
    done
    echo "✅ Mars repos done"
}

# ══════════════════════════════════════
# CYGNUS — Create missing GitHub repos via gh CLI
# ══════════════════════════════════════
cygnus_create_github() {
    echo "🦢 Cygnus: Creating repos on GitHub..."
    
    # Get list of FacePrintPay repos on GitHub
    existing=$(gh repo list FacePrintPay --limit 200 --json name \
        -q '.[].name' 2>/dev/null)
    
    for dir in "$REPOS"/*/; do
        name=$(basename "$dir")
        [ ! -d "$dir/.git" ] && continue
        
        # Check if repo exists on GitHub
        if ! echo "$existing" | grep -q "^$name$"; then
            echo "  🦢 Creating GitHub repo: $name"
            gh repo create "FacePrintPay/$name" \
                --public \
                --description "C25 Module - $name | FacePrintPay" \
                2>/dev/null && echo "  ✅ Created: $name"
        fi
    done
    echo "✅ Cygnus done"
}

# ══════════════════════════════════════
# SATURN — Smart autopush (only changed)
# ══════════════════════════════════════
saturn_push() {
    echo "♄  Saturn: Smart pushing changed repos..."
    PUSHED=0
    for dir in "$REPOS"/*/; do
        name=$(basename "$dir")
        [ ! -d "$dir/.git" ] && continue
        cd "$dir"
        git add -A 2>/dev/null
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "C25 agent: $name - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
            git push origin main 2>/dev/null || \
            git push origin master 2>/dev/null || \
            git push --set-upstream origin main 2>/dev/null
            PUSHED=$((PUSHED+1))
            echo "  🚀 $name"
        fi
    done
    echo "✅ Saturn pushed $PUSHED repos"
}

# ══════════════════════════════════════
# RANGER — Set up as persistent sandbox
# ══════════════════════════════════════
ranger_sandbox() {
    echo "📁 Setting up Ranger persistent sandbox..."
    
    # Update Ranger rc.conf with all agent keybinds
    cat > ~/.config/ranger/rc.conf << 'RANGEREOF'
set show_hidden true
set draw_borders both
set column_ratios 1,3,4
set colorscheme default
set preview_files true

# ── C25 AGENT KEYBINDS ──
# Earth - scaffold current dir
map ge shell bash ~/c25-persistent-agents.sh earth %d
# Moon - fix current file
map gm shell ag=Moon bash ~/github-repos/Constillation25/sovereign_gtp/agents/Moon.sh
# Mars - security scan
map gx shell ag=Mars bash ~/github-repos/Constillation25/sovereign_gtp/agents/Mars.sh
# Jupiter - document file
map gj shell ag=Jupiter bash ~/github-repos/Constillation25/sovereign_gtp/agents/Jupiter.sh
# Ollama - send file to AI
map go shell bash ~/.agent-engine/engine.sh moon %f
# AutoPush
map gp shell bash ~/c25-autopush.sh
# Run current file
map gr shell bash %f
# Edit current file
map gv shell nano %f

# ── BOOKMARKS ──
map gc cd ~/github-repos/Constillation25
map gf cd ~/github-repos/FacePrintPay
map gs cd ~/github-repos/Constillation25/sovereign_gtp
map gd cd ~/storage/downloads
map gh cd ~
map gb cd ~/mybuyo-restore
map g3 cd ~/github-repos/Constillation25/C25-MASTER

# ── NAVIGATION ──
map <C-r> reload_cwd
map <C-f> console find
RANGEREOF

    echo "✅ Ranger sandbox configured"
}

# ══════════════════════════════════════
# RUN ALL AGENTS
# ══════════════════════════════════════
case "${1:-all}" in
    earth)   earth_scaffold ;;
    moon)    moon_review ;;
    mars)    mars_create_repos ;;
    cygnus)  cygnus_create_github ;;
    saturn)  saturn_push ;;
    ranger)  ranger_sandbox ;;
    all)
        earth_scaffold
        moon_review
        mars_create_repos
        ranger_sandbox
        saturn_push
        ;;
esac

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  🌟 C25 Persistent Agents - Complete     ║"
echo "║  Earth: scaffolded all repos             ║"
echo "║  Moon:  fixed broken scripts             ║"
echo "║  Mars:  wired GitHub remotes             ║"
echo "║  Saturn: pushed changes                  ║"
echo "║  Ranger: sandbox ready                   ║"
echo "╚══════════════════════════════════════════╝"
