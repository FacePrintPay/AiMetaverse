#!/data/data/com.termux/files/usr/bin/bash

AGENT="${1:-helio}"
CATEGORY="$2"
BATCH_SIZE="${3:-25}"
DELAY="${4:-0.1}"

if [ -z "$CATEGORY" ]; then
  echo "Usage: ./batch_send.sh <agent> <category> [batch_size] [delay]"
  echo ""
  echo "Categories:"
  echo "  A_landing_page"
  echo "  B_compliance"
  echo "  C_investor"
  echo "  C_investor_materials"
  echo "  D_county_pilot"
  echo "  E_marketing"
  echo "  F_videocourts_ui"
  echo "  G_legal_ai"
  exit 1
fi

BATCH_FILE="batches/${CATEGORY}.txt"

if [ ! -f "$BATCH_FILE" ]; then
  echo "❌ Batch file not found: $BATCH_FILE"
  exit 1
fi

echo "📤 Sending tasks from $BATCH_FILE"
echo "   → Agent:   $AGENT"
echo "   → Category: $CATEGORY"
echo "   → Count:   $BATCH_SIZE"
echo ""

i=0
while IFS= read -r line; do
  [ -z "$line" ] && continue

  ./send_task.sh "$AGENT" "$CATEGORY" "$line"

  i=$((i + 1))
  [ "$i" -ge "$BATCH_SIZE" ] && break

  sleep "$DELAY"
done < "$BATCH_FILE"

echo ""
echo "✅ Sent $i tasks to $AGENT for $CATEGORY"
