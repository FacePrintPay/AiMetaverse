#!/usr/bin/env bash
# Script to gather Termux home files for Obsidian vault synchronization
set -euo pipefail
TERMUX_HOME="$HOME"
TARGET_DIR="$HOME/storage/shared/Obsidian_Vault_Termux"
echo "Gathering files from $TERMUX_HOME to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
# Copy hidden files and directories
cp -a "$TERMUX_HOME"/.[^.]* "$TARGET_DIR/" 2>/dev/null || true
# Copy visible files and directories
cp -a "$TERMUX_HOME"/* "$TARGET_DIR/" 2>/dev/null || true
# Optional exclusions to avoid large/unnecessary data (uncomment if needed)
# rm -rf "$TARGET_DIR/storage" "$TARGET_DIR/usr"
echo "File gathering complete. All files are in $TARGET_DIR."
echo "You can now open '$TARGET_DIR' as a vault in your Obsidian app to sync it to your phone."
