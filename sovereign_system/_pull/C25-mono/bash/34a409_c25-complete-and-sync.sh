#!/data/data/com.termux/files/usr/bin/bash
# C25 Complete & Sync - Find missing files, build them, push to GitHub

REPOS="$HOME/github-repos/Constillation25"
LOG="$HOME/sovereign_gtp/logs/completion.log"
MODEL="llama3.2:1b"

ask() {
    curl -s --max-time 120 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$1\",\"stream\":false,\"options\":{\"num_predict\":600}}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null
}

echo "🔍 Scanning for incomplete C25 modules..."
echo "[$(date)] C25 Completion Scan Started" >> "$LOG"

COMPLETED=0
SKIPPED=0

# Find all C25 module directories
for dir in "$REPOS"/c25-*/; do
    name=$(basename "$dir")
    
    # Count real code files
    files=$(find "$dir" -name "*.js" -o -name "*.py" \
        -o -name "*.sh" 2>/dev/null | wc -l)
    
    # Check for README
    has_readme=$([ -f "$dir/README.md" ] && echo "1" || echo "0")
    
    # Check for main entry point
    has_main=$([ -f "$dir/index.js" ] || \
               [ -f "$dir/main.py" ] || \
               [ -f "$dir/run.sh" ] && echo "1" || echo "0")

    echo "📦 $name | files:$files | readme:$has_readme | main:$has_main"

    # If missing README - generate it
    if [ "$has_readme" = "0" ]; then
        echo "  📝 Generating README for $name..."
        ask "Write a concise README.md for a C25 module called '$name' 
        that is part of the Constellation25 AI agent system by FacePrintPay.
        Include: purpose, usage, how it connects to other C25 agents.
        Keep it under 50 lines. Output ONLY markdown." \
        > "$dir/README.md"
        echo "  ✅ README created"
        COMPLETED=$((COMPLETED + 1))
    fi

    # If no code files at all - generate starter
    if [ "$files" -eq 0 ]; then
        echo "  ⚡ Generating starter code for $name..."
        ask "Write a starter bash script for a C25 module called '$name'.
        This is part of Constellation25 - a 25 agent AI system running on Termux/Android.
        The script should:
        1. Have proper shebang: #!/data/data/com.termux/files/usr/bin/bash
        2. Log to ~/sovereign_gtp/logs/
        3. Connect to PATHOS server at http://localhost:3000
        4. Do something useful based on the module name
        Output ONLY the bash script." \
        > "$dir/run.sh"
        chmod +x "$dir/run.sh"
        echo "  ✅ Starter run.sh created"
        COMPLETED=$((COMPLETED + 1))
    fi

    # Git add and commit this module
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        git add . 2>/dev/null
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "C25 auto-complete: $name" 2>/dev/null
            git push origin main 2>/dev/null &
            echo "  🚀 Pushed: $name"
        fi
        cd "$REPOS"
    fi

done

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  ✅ C25 Completion Done                  ║"
echo "║  Completed: $COMPLETED modules            ║"
echo "║  Log: ~/sovereign_gtp/logs/completion.log ║"
echo "╚══════════════════════════════════════════╝"

# Final sync of main Constillation25 repo
echo ""
echo "🔄 Syncing main repo to GitHub..."
cd "$REPOS"
git add -A 2>/dev/null
git commit -m "C25 auto-complete sync - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
git push origin main --force
echo "✅ GitHub synced"
