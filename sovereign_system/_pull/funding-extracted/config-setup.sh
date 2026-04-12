#!/data/data/com.termux/files/usr/bin/bash
#==============================================================================
# CONSTELLATION25 CONFIGURATION SETUP
#==============================================================================
set -euo pipefail
CONFIG_FILE="$HOME/constellation25/.autobuild-config.sh"

echo "╔════════════════════════════════════════════════════╗"
echo "║  CONSTELLATION25 - Configuration Setup            ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

cat > "$CONFIG_FILE" << 'HEADER'
#!/data/data/com.termux/files/usr/bin/bash
# Constellation25 Autonomous Build Configuration
# WARNING: Keep this file secure - contains credentials
HEADER

prompt_save() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="${3:-}"
    local is_secret="${4:-false}"
    
    echo -n "$prompt_text"
    [ -n "$default_value" ] && echo -n " [$default_value]"
    echo -n ": "
    
    if [ "$is_secret" = "true" ]; then
        read -s input_value; echo ""
    else
        read input_value
    fi
    
    [ -z "$input_value" ] && [ -n "$default_value" ] && input_value="$default_value"
    echo "export $var_name=\"${input_value//\"/\\\"}\"" >> "$CONFIG_FILE"
    echo "  ✓ Saved"
}

echo "=== SECTION 1: USER IDENTITY ==="
prompt_save "USER_NAME" "Your name" "Cygel White"
prompt_save "USER_EMAIL" "Your email" "hempchoices@gmail.com"
prompt_save "USER_GITHUB" "GitHub username" "FacePrintPay"
echo ""

echo "=== SECTION 2: REPLIT URLs ==="
prompt_save "URL_CONSTELLATION25" "Constellation25 Replit URL" ""
prompt_save "URL_VIRTUAL_TWIN" "Virtual Twin Replit URL" ""
prompt_save "URL_PATHOS" "PaTHos Manager Replit URL" ""
prompt_save "URL_V3RSED" "V3RSed.ai Replit URL" ""
prompt_save "URL_FACEPRINT" "FacePrintPay Replit URL" ""
prompt_save "URL_CONTINUITY" "Continuity Builder Replit URL" ""
echo ""

echo "=== SECTION 3: VERCEL ==="
prompt_save "URL_VERCEL" "Vercel URL" "https://cleanbuildfresh.vercel.app"
prompt_save "VERCEL_PROJECT_ID" "Vercel Project ID" ""
echo ""

echo "=== SECTION 4: SECURITY SECRETS ==="
prompt_save "AUTHORITY_SECRET" "Authority Secret (32+ chars)" "$(openssl rand -hex 32)" "true"
prompt_save "SESSION_SECRET" "Session Secret (32+ chars)" "$(openssl rand -hex 32)" "true"
echo ""

echo "=== SECTION 5: PATHS ==="
prompt_save "BASE_DIR" "Base directory" "$HOME/constellation25"
prompt_save "TOTALRECALL_DIR" "TotalRecall directory" "$HOME/TotalRecall/constellation25"
echo ""

chmod 600 "$CONFIG_FILE"
echo ""
echo "✅ Configuration saved to: $CONFIG_FILE"
echo "Next: bash ~/constellation25/autonomous-self-build.sh"
