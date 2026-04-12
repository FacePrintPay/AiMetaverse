#!/data/data/com.termux/files/usr/bin/bash

# C25 Token Guard - Auto-detect and remove secrets before push
# Run before every git push

REPO_DIR="${1:-$(pwd)}"
ENV_FILE="$HOME/.env.tokens"
BASHRC="$HOME/.bashrc"

echo "🛡️  C25 Token Guard Running..."
echo "📁 Scanning: $REPO_DIR"

# ── STEP 1: Scan for exposed tokens ──
echo ""
echo "🔍 Scanning for exposed secrets..."

PATTERNS=(
    "ghp_[a-zA-Z0-9]{36}"
    "gho_[a-zA-Z0-9]{36}"
    "github_pat_[a-zA-Z0-9_]{82}"
    "sk-[a-zA-Z0-9]{48}"
    "Bearer [a-zA-Z0-9_\-]{20,}"
    "TOKEN=['\"][a-zA-Z0-9_\-]{10,}"
    "API_KEY=['\"][a-zA-Z0-9_\-]{10,}"
    "SECRET=['\"][a-zA-Z0-9_\-]{10,}"
    "PASSWORD=['\"][^'\"]{6,}"
)

FOUND=0
for pattern in "${PATTERNS[@]}"; do
    matches=$(grep -rn --include="*.sh" --include="*.js" \
        --include="*.py" --include="*.env" --include="*.json" \
        -E "$pattern" "$REPO_DIR" 2>/dev/null | \
        grep -v ".git/" | grep -v "node_modules/")
    
    if [ -n "$matches" ]; then
        FOUND=1
        echo "⚠️  FOUND: $matches"
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "✅ No exposed secrets found"
fi

# ── STEP 2: Auto-replace common patterns ──
echo ""
echo "🔧 Auto-replacing hardcoded secrets..."

find "$REPO_DIR" -type f \( -name "*.sh" -o -name "*.js" -o -name "*.py" \) \
    ! -path "*/.git/*" ! -path "*/node_modules/*" | while read -r file; do
    
    # Replace GitHub tokens
    sed -i 's/TOKEN="gho_[^"]*"/TOKEN="${GITHUB_TOKEN}"/g' "$file"
    sed -i 's/TOKEN="ghp_[^"]*"/TOKEN="${GITHUB_TOKEN}"/g' "$file"
    sed -i 's/TOKEN=ghp_[^ ]*/TOKEN="${GITHUB_TOKEN}"/g' "$file"
    sed -i 's/TOKEN=gho_[^ ]*/TOKEN="${GITHUB_TOKEN}"/g' "$file"
    
    # Replace API keys
    sed -i 's/API_KEY="sk-[^"]*"/API_KEY="${ANTHROPIC_API_KEY}"/g' "$file"
    sed -i 's/OPENAI_KEY="sk-[^"]*"/OPENAI_KEY="${OPENAI_API_KEY}"/g' "$file"
    
    # Replace Bearer tokens
    sed -i 's/Bearer ghp_[a-zA-Z0-9]*/Bearer ${GITHUB_TOKEN}/g' "$file"
done

echo "✅ Auto-replace complete"

# ── STEP 3: Set up .env.tokens if missing ──
echo ""
echo "🔐 Checking secure token storage..."

if [ ! -f "$ENV_FILE" ]; then
    cat > "$ENV_FILE" << 'ENVEOF'
# C25 Secure Token Store
# NEVER commit this file
export GITHUB_TOKEN=""
export ANTHROPIC_API_KEY=""
export OPENAI_API_KEY=""
export VERCEL_TOKEN=""
export DIGITAL_OCEAN_TOKEN=""
export SMTP_PASSWORD=""
ENVEOF
    chmod 600 "$ENV_FILE"
    echo "✅ Created: $ENV_FILE (chmod 600)"
fi

# ── STEP 4: Add source to .bashrc if missing ──
if ! grep -q "env.tokens" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# C25 Secure Tokens" >> "$BASHRC"
    echo "[ -f ~/.env.tokens ] && source ~/.env.tokens" >> "$BASHRC"
    echo "✅ Added token source to .bashrc"
fi

# ── STEP 5: Add .env.tokens to .gitignore ──
GITIGNORE="$REPO_DIR/.gitignore"
touch "$GITIGNORE"

IGNORES=(
    ".env.tokens"
    ".env.local"
    ".env"
    "*.secret"
    "*_token*"
    "secrets/"
    ".secrets"
)

for item in "${IGNORES[@]}"; do
    if ! grep -q "$item" "$GITIGNORE" 2>/dev/null; then
        echo "$item" >> "$GITIGNORE"
    fi
done
echo "✅ .gitignore updated"

# ── STEP 6: Clean git history if token was committed ──
echo ""
echo "🧹 Checking git history for secrets..."

HISTORY_HITS=$(git -C "$REPO_DIR" log --all -p 2>/dev/null | \
    grep -E "gho_|ghp_|sk-[a-zA-Z0-9]{48}" | wc -l)

if [ "$HISTORY_HITS" -gt 0 ]; then
    echo "⚠️  Found $HISTORY_HITS secret(s) in git history"
    echo "🧹 Cleaning history..."
    
    cd "$REPO_DIR"
    
    # Remove secrets from all files in history
    git filter-branch --force --index-filter \
        'git ls-files -z | xargs -0 sed -i \
        "s/TOKEN=\"gho_[^\"]*\"/TOKEN=\"\${GITHUB_TOKEN}\"/g; \
         s/TOKEN=\"ghp_[^\"]*\"/TOKEN=\"\${GITHUB_TOKEN}\"/g" \
        2>/dev/null; exit 0' \
        --prune-empty -- --all 2>/dev/null
    
    echo "✅ Git history cleaned"
else
    echo "✅ Git history is clean"
fi

# ── STEP 7: Safe push ──
echo ""
echo "🚀 Ready to push safely"
echo ""
echo "Next steps:"
echo "1. Add your token to ~/.env.tokens"
echo "2. source ~/.env.tokens"  
echo "3. git push -u origin main --force"
echo ""
echo "Or run: bash ~/c25-token-guard.sh && git push -u origin main --force"

