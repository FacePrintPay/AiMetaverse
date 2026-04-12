#!/bin/bash
# Paths - Adjust 'MyVault' to your actual Obsidian folder name
VAULT_PATH="$HOME/storage/shared/Documents/MyVault"
REMOTE_PATH="gdrive:ObsidianVault"

echo "--- Starting Obsidian Sync $(date) ---"

# 1. Sync Termux Files to Vault (Backup Termux config/home)
echo "Backing up Termux home to vault..."
cp -r ~/.bashrc "$VAULT_PATH/TermuxBackup/"
cp -r ~/.config "$VAULT_PATH/TermuxBackup/"

# 2. Pull latest from Google Drive
echo "Pulling updates from Google Drive..."
rclone sync "$REMOTE_PATH" "$VAULT_PATH" --vfs-cache-mode writes

# 3. Git Sync (If you use 
