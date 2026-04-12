#!/bin/bash
set -euo pipefail
# REPO: AiKre8tive-Stargate | FILE: platform/scripts/generate_qr_affiliate.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash

# === CONFIG ===
AFFILIATE_URL="https://blackbox.ai?ref=MrGGTP"
OUTPUT="$HOME/AiKre8tiveGenesis/platform/assets/qr_blackbox.png"

# === GENERATE QR ===
mkdir -p "$(dirname "$OUTPUT")"
if command -v qrencode >/dev/null 2>&1; then
  qrencode -o "$OUTPUT" -s 10 -m 3 "$AFFILIATE_URL"
  echo "✅ QR Code saved at: $OUTPUT"
  termux-open "$OUTPUT"
else
  echo "❌ qrencode is not installed. Run: pkg install qrencode"
fi
