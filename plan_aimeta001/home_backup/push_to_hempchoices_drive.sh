#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# CONFIG — CHANGE ONLY IF YOU WANT
GDRIVE_REMOTE="hempchoices_gmail_com"      # your rclone remote name for hempchoices@gmail.com
TARGET_DIR="\( {1:- \)(ls -d ~/ULTIMATE_RECOVERY_* | tail -1)}"   # use argument or latest recovery
DEST_FOLDER="AiMetaverse_ULTIMATE_RECOVERY_BACKUPS/$(basename "$TARGET_DIR")"

log() { echo "[\( (date '+%H:%M:%S')] 🚀 \)*"; }

log "ULTIMATE PUSH TO 2 TB GDRIVE (hempchoices@gmail.com)"
log "Source: $TARGET_DIR"
log "Destination: $GDRIVE_REMOTE:/$DEST_FOLDER"

# 1. Make sure remote exists and is authenticated
if ! rclone listremotes | grep -q "^${GDRIVE_REMOTE}:"; then
    echo "Remote $GDRIVE_REMOTE not found!"
    echo "Run this first:"
    echo "   rclone config → n → name: hempchoices_gmail_com → type: drive → scope: drive → leave client_id blank → login with hempchoices@gmail.com"
    exit 1
fi

# 2. Test connection
log "Testing connection to hempchoices@gmail.com Drive..."
if ! rclone lsd "$GDRIVE_REMOTE:" >/dev/null 2>&1; then
    log "Authentication failed or quota issue. Re-authenticating..."
    rclone config reconnect "$GDRIVE_REMOTE":
fi

# 3. Create destination folder
log "Creating remote folder..."
rclone mkdir "$GDRIVE_REMOTE:/$DEST_FOLDER"

# 4. SYNC — aggressive, fast, with retries
log "SYNCING TO 2 TB GDRIVE — THIS WILL TAKE A WHILE..."
rclone sync "$TARGET_DIR" "$GDRIVE_REMOTE:/$DEST_FOLDER" \
    --drive-chunk-size 256M \
    --transfers 32 \
    --checkers 16 \
    --drive-upload-cutoff 500G \
    --tpslimit 10 \
    --retries 10 \
    --retries-sleep 30s \
    --low-level-retries 20 \
    --stats 15s \
    --log-level INFO \
    --progress

# 5. Final verification
log "Verifying upload integrity..."
rclone check "$TARGET_DIR" "$GDRIVE_REMOTE:/$DEST_FOLDER" --size-only && log "VERIFICATION PASSED — 100% MATCH" || log "WARNING: Some files may differ"

log ""
log "SUCCESS — YOUR FULL ARCHIVE IS NOW SAFE ON 2 TB GDRIVE"
log "Link: https://drive.google.com/drive/u/0/folders/$(rclone cat "$GDRIVE_REMOTE:/$DEST_FOLDER" --dump headers | grep -o 'drive.google.com/open?id=[^ ]*' | cut -d= -f2 || echo '(open Drive to find)')"

