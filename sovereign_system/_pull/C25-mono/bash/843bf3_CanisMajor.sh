#!/data/data/com.termux/files/usr/bin/bash
# CanisMajor - Guard/Security Agent
# Automatically routes secrets to .env.tokens and replaces with env vars

AGENT="CanisMajor"
LOG="$HOME/sovereign_gtp/logs/canismajor.log"
ENV_FILE="$HOME/.env.tokens"
REPO="${1:-$HOME/github-repos/Constillation25}"

echo "[$AGENT] $(date '+%Y-%m-%d %H:%M:%S') - Guard activated" >> "$LOG"
echo "🛡️  CanisMajor - Secret Router"
echo "📁 Scanning: $REPO"

# ── STEP 1: Find all real secrets ──
declare -A SECRET_MAP

while IFS= read -r line; do
    FILE=$(echo "$line" | cut -d: -f1)
    LINENUM=$(echo "$line" | cut -d: -f2)
    MATCH=$(echo "$line" | cut -d: -f3-)
    
    # Extract the actual secret value
    VALUE=$(echo "$MATCH" | grep -oE '"[^"]+"' | tail -1 | tr -d '"')
    KEY=$(echo "$MATCH" | grep -oE '[A-Z_]+=' | head -1 | tr -d '=')
    
    # Skip placeholders
    if echo "$VALUE" | grep -qE "your_|YOUR_|placeholder|example|supersecret|xxx"; then
        echo "  ⚪ Placeholder (skip): $KEY in $FILE:$LINENUM"
        continue
    fi
    
    # Real secret found
    echo "  🔴 REAL SECRET: $KEY = ${VALUE:0:8}... in $FILE:$LINENUM"
    SECRET_MAP["$KEY"]="$VALUE"
    
    # Replace in file with env var reference
    sed -i "s|$KEY=\"$VALUE\"|$KEY=\"\${$KEY}\"|g" "$FILE"
    echo "  ✅ Replaced in: $FILE"
    
done < <(grep -rn --include="*.sh" --include="*.js" --include="*.py" --include="*.env" \
    -E '(TOKEN|API_KEY|SECRET|PASSWORD|KEY)=["\x27][^"\x27]{8,}["\x27]' \
    "$REPO" 2>/dev/null | grep -v ".git/" | grep -v "node_modules/")

# ── STEP 2: Write real secrets to .env.tokens ──
if [ ${#SECRET_MAP[@]} -gt 0 ]; then
    echo "" >> "$ENV_FILE"
    echo "# Auto-routed by CanisMajor - $(date '+%Y-%m-%d %H:%M:%S')" >> "$ENV_FILE"
    
    for KEY in "${!SECRET_MAP[@]}"; do
        VALUE="${SECRET_MAP[$KEY]}"
        # Only add if not already in .env.tokens
        if ! grep -q "^export $KEY=" "$ENV_FILE" 2>/dev/null; then
            echo "export $KEY=\"$VALUE\"" >> "$ENV_FILE"
            echo "  📥 Saved to .env.tokens: $KEY"
        fi
    done
    
    chmod 600 "$ENV_FILE"
    echo "  🔒 .env.tokens secured (chmod 600)"
fi

# ── STEP 3: Ensure .env.tokens is gitignored everywhere ──
find "$REPO" -name ".gitignore" | while read -r gitignore; do
    if ! grep -q ".env.tokens" "$gitignore" 2>/dev/null; then
        echo ".env.tokens" >> "$gitignore"
        echo "*.secret" >> "$gitignore"
        echo "  ✅ Updated: $gitignore"
    fi
done

# ── STEP 4: Source .env.tokens ──
if ! grep -q "env.tokens" "$HOME/.bashrc"; then
    echo "[ -f ~/.env.tokens ] && source ~/.env.tokens" >> "$HOME/.bashrc"
fi
source "$ENV_FILE" 2>/dev/null

echo ""
echo "[$AGENT] Scan complete - $(date '+%H:%M:%S')" >> "$LOG"
echo "✅ CanisMajor done. Secrets routed. Repo is clean."
