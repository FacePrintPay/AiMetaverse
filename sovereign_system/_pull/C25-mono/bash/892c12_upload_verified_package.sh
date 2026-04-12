#!/data/data/com.termux/files/usr/bin/bash
# ════════════════════════════════════════════════════════════════
# ✅ CLOUDLFARE R2 ONE-SHOT UPLOADER (FIXED)
# Builds config (only if missing) → tests → uploads verified package
# ════════════════════════════════════════════════════════════════

ACCOUNT_ID="your_actual_account_id_here"
ACCESS_KEY="your_R2_access_key_here"
SECRET_KEY="your_R2_secret_key_here"
BUCKET="TotalRecall"
TARGET_PATH="legal"
FILE="$HOME/TotalRecall/complaint_project/legal_strategy_package_20251108_022941.tar.gz"
CONF="$HOME/.config/rclone/rclone.conf"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🧭 CLOUDLFARE R2 UPLOADER INITIALIZING..."
echo "═══════════════════════════════════════════════════════════════"

# Build config only if it doesn't exist
if [ ! -f "$CONF" ]; then
    echo "[⚙️] Creating new rclone config..."
    mkdir -p "$(dirname "$CONF")"
    cat > "$CONF" <<CFG
[final]
type = s3
provider = Cloudflare
access_key_id = $ACCESS_KEY
secret_access_key = $SECRET_KEY
endpoint = https://$ACCOUNT_ID.r2.cloudflarestorage.com
acl = private
CFG
else
    echo "[ℹ️] Using existing rclone config..."
fi

grep endpoint "$CONF"

echo "[🧪] Testing R2 connection..."
rclone lsd final: >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Connection failed — check account ID or keys in:"
    echo "   $CONF"
    exit 1
fi

echo "[📁] Ensuring bucket path exists..."
rclone mkdir final:${BUCKET}/${TARGET_PATH} >/dev/null 2>&1 || \
echo "   (Note: R2 S3 doesn't use empty folders — safe to continue)"

echo "[🚀] Uploading verified archive..."
rclone copy "$FILE" final:${BUCKET}/${TARGET_PATH}/ --progress
if [ $? -ne 0 ]; then
    echo "❌ Upload failed."
    exit 1
fi

echo "[🔍] Confirming uploaded file..."
rclone ls final:${BUCKET}/${TARGET_PATH}/ | grep "$(basename "$FILE")"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ UPLOAD COMPLETE — Cloudflare R2 now holds your legal package."
echo "Bucket: $BUCKET"
echo "Path:   $TARGET_PATH/"
echo "═══════════════════════════════════════════════════════════════"
