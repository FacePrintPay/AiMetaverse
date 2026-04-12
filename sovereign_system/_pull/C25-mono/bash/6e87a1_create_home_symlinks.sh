#!/usr/bin/env bash
set -e
export HOME="/data/data/com.termux/files/home"
cd "$HOME" || exit 1
echo "🏠 Creating HOME symlink structure"
echo ""
# Helper: create symlink if missing
link() {
  local target="$1"
  local name="$2"
  if [ -L "$name" ]; then
    echo "✔ Exists: $name -> $(readlink "$name")"
  elif [ -e "$name" ]; then
    echo "⚠ Skipped (real file exists): $name"
  elif [ -e "$target" ]; then
    ln -s "$target" "$name"
    echo "🔗 Linked: $name -> $target"
  else
    echo "⚠ Target missing: $target"
  fi
}
# Core links
link "$HOME/storage/shared"            "shared"
link "$HOME/storage/shared/Obsidian"   "obsidian"
link "$HOME/storage/shared/Obsidian/Obsidian" "vaults"
# Optional scripts/bin directory
mkdir -p "$HOME/scripts"
link "$HOME/scripts" "bin"
echo ""
echo "✅ HOME symlink structure complete"
