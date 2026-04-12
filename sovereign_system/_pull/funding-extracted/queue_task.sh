#!/data/data/com.termux/files/usr/bin/bash
AGENT="${1:-earth}"
ACTION="${2:-ping}"
TARGET="${3:-none}"
C25="$HOME/constellation25"
TS=$(date "+%Y%m%d_%H%M%S")
ID="task_${TS}_${AGENT}"
SHA=$(echo "$ID-$ACTION-$TARGET" | sha256sum | cut -d' ' -f1)
FILE="$C25/tasks/${ID}.json"
cat > "$FILE" << JSON
{
  "id": "$ID",
  "agent": "$AGENT",
  "action": "$ACTION",
  "target": "$TARGET",
  "priority": 1,
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "sha256": "$SHA",
  "status": "pending"
}
JSON
echo "  ✅ Task queued: $FILE"
echo "  SHA256: $SHA"
echo "$SHA  $FILE" >> "$C25/logs/totalrecall_manifest.log"
