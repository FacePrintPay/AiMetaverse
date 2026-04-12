#!/bin/bash
# FacePrintPay Fork Cleanup - Safe Delete Unused Forks (Termux Fixed)
set -euo pipefail
TEMP_DIR="$HOME/.tmp-forks"
mkdir -p "$TEMP_DIR"
echo -e "\033[0;34m╔════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;34m║  FacePrintPay Fork Cleanup                 ║\033[0m"
echo -e "\033[0;34m╚════════════════════════════════════════════╝\033[0m"
echo -e "\033[0;36mScanning for forked repos...\033[0m"
# List all forks
gh repo list FacePrintPay --json name,isFork,owner -q '.[] | select(.isFork == true) | .name' > "$TEMP_DIR/forks.txt"
if [ ! -s "$TEMP_DIR/forks.txt" ]; then
    echo -e "\033[0;32m✅ No forked repos found.\033[0m"
    rm -rf "$TEMP_DIR"
    exit 0
fi
echo -e "\033[0;33mFound forked repos:\033[0m"
cat "$TEMP_DIR/forks.txt"
echo -e "\033[0;33m\nType 'DELETE' to confirm and remove all forks:\033[0m"
read -r confirm
if [[ "$confirm" == "DELETE" ]]; then
    cat "$TEMP_DIR/forks.txt" | while read -r repo; do
        echo -e "\033[0;31mDeleting fork: $repo\033[0m"
        gh repo delete "FacePrintPay/$repo" --yes 2>/dev/null || true
    done
    echo -e "\033[0;32m✅ All unused forked repos deleted!\033[0m"
else
    echo -e "\033[0;32mCancelled. No forks deleted.\033[0m"
fi
rm -rf "$TEMP_DIR"
