#!/bin/bash
set -e

# EDIT THESE 4 LINES ONLY
LOCAL_FOLDER="/storage/emulated/0/Download/48287-files"   # change only if your folder is somewhere else
ACCOUNT_ID="your-account-id-here"                        # ← 32 characters from R2 dashboard
BUCKET_NAME="your-bucket-name-here"
ACCESS_KEY="your-access-key-id"
SECRET_KEY="your-secret-access-key"

echo "Cloudflare R2 – uploading 48,287 files (~31 GB)"

# Installing rclone..."
pkg install rclone -y 2>/dev/null || true

echo "Creating R2 remote..."
rclone config delete r2 2>/dev/null || true
rclone config create r2 s3 provider=Cloudflare \
  access_key_id="$ACCESS_KEY" \
  secret_access_key="$SECRET_KEY" \
  region=auto \
  endpoint="https://$ACCOUNT_ID.r2.cloudflarestorage.com" \
  acl=private --non-interactive >/dev/null

echo "Starting upload – this will take 1–4 hours depending on your connection"
rclone sync "$LOCAL_FOLDER" "r2:$BUCKET_NAME/backup-48k-files" \
  --progress \
  --stats 10s \
  --transfers 40 \
  --checkers 40 \
  --s3-upload-cutoff 0 \
  --s3-chunk-size 5M \
  --s3-upload-concurrency 10 \
  --retries 10 \
  --fast-list \
  -v

echo
echo "ALL DONE! Your files are now in R2"
echo "→ https://dash.cloudflare.com → R2 → $BUCKET_NAME → backup-48k-files"
echo "Re-run this script anytime to add or update files"
