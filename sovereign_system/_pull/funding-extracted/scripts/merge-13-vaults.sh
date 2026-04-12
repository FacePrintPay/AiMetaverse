#!/bin/bash
set -eo pipefail
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Constellation25 - 13 Vault Merger                    ║"
echo "╚══════════════════════════════════════════════════════════╝"

DEST="/data/data/com.termux/files/home/merged-vault"
mkdir -p "$DEST"

# Find and merge all WideOpen vaults
echo "Merging WideOpen vaults..."
find /sdcard -type d -name "*WideOpen*" 2>/dev/null | while read vault; do
    echo "  → $(basename "$vault")"
    cp -rn "$vault/"* "$DEST/" 2>/dev/null || true
done

# Merge AiKre8tive vaults
echo "Merging AiKre8tive vaults..."
find /sdcard -type d -name "*AiKre8tive*" 2>/dev/null | while read vault; do
    echo "  → $(basename "$vault")"
    cp -rn "$vault/"* "$DEST/" 2>/dev/null || true
done

# Merge Obsidian vaults
echo "Merging Obsidian vaults..."
find /sdcard -type d -name "*Obsidian*" 2>/dev/null | while read vault; do
    echo "  → $(basename "$vault")"
    cp -rn "$vault/"* "$DEST/" 2>/dev/null || true
done

# Merge Documents
echo "Merging Documents..."
find /sdcard -type d -name "*Documents*" 2>/dev/null | while read vault; do
    echo "  → $(basename "$vault")"
    cp -rn "$vault/"* "$DEST/" 2>/dev/null || true
done

# Merge C25-Vault
echo "Merging C25-Vault..."
cp -rn /data/data/com.termux/files/home/C25-Vault/* "$DEST/" 2>/dev/null || true

# Merge Constellation25
echo "Merging Constellation25..."
cp -rn /data/data/com.termux/files/home/Constellation25/* "$DEST/" 2>/dev/null || true

echo ""
echo "✅ MERGE COMPLETE!"
echo "Files: $(find "$DEST" -type f 2>/dev/null | wc -l)"
echo "Location: $DEST"
