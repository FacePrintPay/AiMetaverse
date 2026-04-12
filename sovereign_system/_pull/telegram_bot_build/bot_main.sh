#!/data/data/com.termux/files/usr/bin/bash
# Telegram Bot - Local Termux Version

source .env

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Error: Token not found. Please set TELEGRAM_BOT_TOKEN in .env"
    exit 1
fi

echo "[*] Bot Starting..."
echo "[*] Listening for updates (Polling)..."

# Simple polling loop (Works in Termux, NOT on Vercel)
while true; do
    # Get updates
    UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates")
    
    # Extract last message ID (Basic implementation)
    LAST_ID=$(echo $UPDATES | jq -r '.result[-1].update_id')
    TEXT=$(echo $UPDATES | jq -r '.result[-1].message.text')
    CHAT_ID=$(echo $UPDATES | jq -r '.result[-1].message.chat.id')
    
    if [ "$TEXT" != "null" ] && [ -n "$TEXT" ]; then
        echo "[*] Received: $TEXT"
        
        # Send reply
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\": \"$CHAT_ID\", \"text\": \"Echo: $TEXT\"}" > /dev/null
            
        # Mark as read (offset)
        curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=$((LAST_ID + 1))" > /dev/null
    fi
    
    sleep 2
done
