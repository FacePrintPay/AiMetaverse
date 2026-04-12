#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
for p in jq fd ripgrep fzf parallel bc git curl; do pkg list-installed 2>/dev/null | grep -q "^$p " || pkg install -y "$p"; done
echo "[OK] Done"
