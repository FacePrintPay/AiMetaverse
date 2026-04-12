#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="mercury"
INBOX="$C25/mercury_inbox"
mkdir -p "$INBOX"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  MSGS=$(find "$INBOX" -name "*.msg" 2>/dev/null | wc -l)
  for MSG in "$INBOX"/*.msg; do
    [ -f "$MSG" ] || continue
    CONTENT=$(cat "$MSG")
    echo "[$TS] [$NAME] DELIVERED: $CONTENT" >> "$LOGS/constellation25.log"
    termux-notification --title "C25:Mercury" --content "$CONTENT" 2>/dev/null
    mv "$MSG" "$MSG.sent"
  done
  echo "[$TS] [$NAME] INBOX_CHECK msgs_pending:$MSGS" >> "$LOGS/mercury.log"
  sleep 30
done
