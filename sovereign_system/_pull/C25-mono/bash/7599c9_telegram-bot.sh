#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Load config
source "$HOME/constellation25/.telegram-config"

BASE_DIR="${BASE_DIR:-$HOME/constellation25}"
LOGS_DIR="${BASE_DIR}/logs"
TOTALRECALL_DIR="${TOTALRECALL_DIR:-$HOME/TotalRecall/constellation25}"
mkdir -p "$LOGS_DIR"

# Telegram API functions
tg_send() {
    local msg="$1"
    local chat="${2:-$TELEGRAM_CHAT_ID}"
    curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$chat" \
        -d "text=$msg" \
        -d "parse_mode=Markdown" >> "$LOGS_DIR/tg.log" 2>&1
}

tg_send_file() {
    local file="$1"
    local caption="$2"
    local chat="${3:-$TELEGRAM_CHAT_ID}"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
        -F "chat_id=$chat" \
        -F "document=@$file" \
        -F "caption=$caption" >> "$LOGS_DIR/tg.log" 2>&1
}

# Command handlers
handle_status() {
    local chat_id="$1"
    local status=$(bash "$BASE_DIR/run.sh" status 2>&1)
    tg_send "🤖 *Constellation25 Status*

$status

🔐 TotalRecall: Active
🌌 #Cyg-N-Us #LegYc" "$chat_id"
}

handle_build() {
    local chat_id="$1"
    local input="${2:-$BASE_DIR/json-input/test.json}"
    local out=$(bash "$BASE_DIR/run.sh" json "$input" 2>&1)
    tg_send "🚀 *Build Complete*

$out" "$chat_id"
}

handle_help() {
    local chat_id="$1"
    tg_send "🤖 *Agentik Agents Bot Commands*

/status - System status
/build - Run build
/manifesto - Generate manifesto
/help - Show this help

🔐 Powered by Constellation25
🌌 #Cyg-N-Us #LegYc" "$chat_id"
}

handle_manifesto() {
    local chat_id="$1"
    local manifesto="$BASE_DIR/docs/MANIFESTO.md"
    if [ -f "$manifesto" ]; then
        tg_send_file "$manifesto" "📜 Constellation25 Manifesto" "$chat_id"
    else
        tg_send "⚠️ Manifesto not found. Run: bash ~/constellation25/integrations/ollama-bridge.sh manifesto" "$chat_id"
    fi
}

# Poll for updates
poll_updates() {
    local offset="${1:-0}"
    local updates=$(curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/getUpdates?offset=$offset&timeout=30")
    
    # Parse and handle updates
    echo "$updates" | jq -r '.result[]? | "\(.update_id)|\(.message.chat.id)|\(.message.text)"' 2>/dev/null | while IFS='|' read -r uid chat text; do
        echo "[TG] $chat: $text" >> "$LOGS_DIR/tg.log"
        
        # Log to TotalRecall
        local hash=$(echo "TELEGRAM_CMD $chat $text $(date)" | sha256sum | cut -d' ' -f1)
        echo "$hash  [$(date -u)] [TELEGRAM] ChatId:$chat Command:$text" >> "$TOTALRECALL_DIR/blockchain_manifest.txt"
        
        # Handle commands
        case "$text" in
            /start)
                tg_send "👋 Welcome to Agentik Agents!

I'm your Constellation25 assistant.

Commands:
/status - System status
/build - Run build
/manifesto - Get manifesto
/help - Show help" "$chat"
                ;;
            /status) handle_status "$chat" ;;
            /build) handle_build "$chat" ;;
            /manifesto) handle_manifesto "$chat" ;;
            /help) handle_help "$chat" ;;
            *)
                tg_send "❓ Unknown command. Use /help for available commands." "$chat"
                ;;
        esac
    done
    
    # Return new offset
    echo "$updates" | jq -r '.result[-1]?.update_id + 1 // 0' 2>/dev/null
}

# Main loop
main() {
    echo "[INFO] Agentik Agents Bot starting..."
    echo "[INFO] Bot: @agentik_agents_bot"
    echo "[INFO] Logs: $LOGS_DIR/tg.log"
    
    local offset=0
    while true; do
        offset=$(poll_updates "$offset")
        sleep 2
    done
}

# Run
main "$@"
