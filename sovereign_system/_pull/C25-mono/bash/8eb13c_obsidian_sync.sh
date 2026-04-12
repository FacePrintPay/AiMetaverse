#!/usr/bin/env bash

# CONFIGURATION
VAULT_PATH="$HOME/storage/shared/Documents/MyVault"
REMOTE_PATH="gdrive:ObsidianVault"
LOG_FILE="$HOME/sync_log.txt"

# Ensure directories exist
mkdir -p "$VAULT_PATH/TermuxBackup"

echo "--- Sync Started: $(date) ---" >> "$LOG_FILE"

# 1. PULL FROM CLOUD (Gmail/Drive files)
echo "Pulling updates from Google Drive..." >> "$LOG_FILE"
rclone sync "$REMOTE_PATH" "$VAULT_PATH" --vfs-cache-mode writes >> "$LOG_FILE" 2>&1

# 2. BACKUP TERMUX ENVIRONMENT
echo "Syncing Termux home to Vault..." >> "$LOG_FILE"
cp ~/.bashrc ~/.zshrc "$VAULT_PATH/TermuxBackup/" 2>/dev/null
cp -r ~/.config "$VAULT_PATH/TermuxBackup/" 2>/dev/null

# 3. GIT VERSION CONTROL (If Vault is a repo)
if [ -d "$VAULT_PATH/.git" ]; then
    echo "Running Git Sync..." >> "$LOG_FILE"
    cd "$VAULT_PATH" || exit
    git add .
    git commit -m "Auto-sync $(date)" --quiet
    git pull --rebase --quiet
    git push --quiet
fi

# 4. PUSH TO CLOUD (Upload phone notes)
echo "Pushing final state to Google Drive..." >> "$LOG_FILE"
rclone sync "$VAULT_PATH" "$REMOTE_PATH" >> "$LOG_FILE" 2>&1

echo "--- Sync Complete: $(date) ---" >> "$LOG_FILE"
