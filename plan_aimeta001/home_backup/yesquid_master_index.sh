#!/data/data/com.termux/files/usr/bin/bash
# SOVEREIGN MASTER INDEX
# One script to index every piece of code you own under $HOME
# without duplicating node_modules hell.

set -euo pipefail

MASTER_ROOT="$HOME/SOVEREIGN_MASTER"
MANIFEST_DIR="$MASTER_ROOT/manifests"
SNAPSHOT_DIR="$MASTER_ROOT/snapshots"

mkdir -p "$MASTER_ROOT" "$MANIFEST_DIR" "$SNAPSHOT_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
manifest="$MANIFEST_DIR/code_manifest_$timestamp.txt"

echo "🛰  SOVEREIGN MASTER INDEX"
echo "    MASTER_ROOT = $MASTER_ROOT"
echo "    MANIFEST    = $manifest"
echo

# Find all code files but skip heavy/binary trees
find "$HOME" \
  \( -path "*/node_modules/*" -o -path "*/.git/*" -o -path "*/__pycache__/*" -o -path "*/dist/*" -o -path "*/build/*" \) -prune -o \
  -type f \
  \( -iname "*.sh" -o -iname "*.py" -o -iname "*.js" -o -iname "*.ts" -o -iname "*.tsx" -o -iname "*.jsx" -o -iname "*.json" -o -iname "*.yml" -o -iname "*.yaml" -o -iname "Makefile" -o -iname "Dockerfile" \) \
  -print | sort > "$manifest"

echo "[✓] Code manifest written:"
echo "    $manifest"
echo

# Update "latest" pointer for easy access
ln -sf "$manifest" "$MANIFEST_DIR/latest_manifest.txt"

echo "[✓] Latest manifest symlinked at:"
echo "    $MANIFEST_DIR/latest_manifest.txt"

# Optional: snapshot basic tree structure
tree_out="$SNAPSHOT_DIR/home_tree_$timestamp.txt"
if command -v tree >/dev/null 2>&1; then
  echo "[*] Capturing shallow tree snapshot with 'tree'..."
  tree -L 3 "$HOME" > "$tree_out" || true
  echo "[✓] Tree snapshot → $tree_out"
else
  echo "[i] 'tree' not installed; skip tree snapshot. Install with: pkg install tree"
fi

echo
echo "🚀 SOVEREIGN MASTER INDEX COMPLETE."
