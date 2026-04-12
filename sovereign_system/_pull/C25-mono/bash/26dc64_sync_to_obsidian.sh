#!/bin/bash

# Complete synchronization script for Termux to Obsidian vault
# This script syncs Termux home directory and shared storage to a dedicated folder in your Obsidian vault
# Adjust paths if your vault name or structure differs

# Define paths
VAULT_ROOT=~/storage/shared/Obsidian
VAULT_NAME="Obsidian"  # Change if your vault has a different folder name
SYNC_FOLDER="$VAULT_ROOT/$VAULT_NAME/Termux_Sync"
HOME_SYNC="$SYNC_FOLDER/Home"
SAVED_SYNC="$SYNC_FOLDER/Saved"

# Ensure storage access (run termux-setup-storage first if not done)
if [ ! -d ~/storage/shared ]; then
    echo "Error: Shared storage not accessible. Run 'termux-setup-storage' first."
    exit 1
fi

# Create sync directories if they don't exist
mkdir -p "$HOME_SYNC"
mkdir -p "$SAVED_SYNC"

# Sync Termux home directory (visible and hidden files, excluding large/unnecessary items)
echo "Syncing Termux home directory..."
rsync -av --exclude='.git' --exclude='*.tmp' --exclude='*.log' --exclude='*.cache' --exclude='node_modules' ~/ "$HOME_SYNC/"

# Sync relevant shared storage directories (customize as needed)
echo "Syncing shared storage directories..."
rsync -av ~/storage/shared/Downloads/ "$SAVED_SYNC/Downloads/" 2>/dev/null || mkdir -p "$SAVED_SYNC/Downloads"
rsync -av ~/storage/shared/Documents/ "$SAVED_SYNC/Documents/" 2>/dev/null || mkdir -p "$SAVED_SYNC/Documents"
rsync -av ~/storage/shared/DCIM/ "$SAVED_SYNC/DCIM/" 2>/dev/null || mkdir -p "$SAVED_SYNC/DCIM"
rsync -av ~/storage/shared/Pictures/ "$SAVED_SYNC/Pictures/" 2>/dev/null || mkdir -p "$SAVED_SYNC/Pictures"

# Generate integrity hashes
echo "Generating file hashes for verification..."
find "$SYNC_FOLDER" -type f -exec sha256sum {} + > "$SYNC_FOLDER/hashes.txt" 2>/dev/null

# Completion message
echo "Synchronization complete."
echo "Synced data is now available in your Obsidian vault at:"
echo "  Termux_Sync/Home (Termux files)"
echo "  Termux_Sync/Saved (Shared storage folders)"
echo ""
echo "To open directly in Obsidian, use this command in Termux:"
echo "am start -a android.intent.action.VIEW -d 'obsidian://open?vault=Obsidian&file=Termux_Sync'"

# Optional: Automatically open Obsidian (uncomment if desired)
# am start -a android.intent.action.VIEW -d "obsidian://open?vault=Obsidian&file=Termux_Sync"
