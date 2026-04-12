#!/data/data/com.termux/files/usr/bin/bash
set -e
command -v termux-clipboard-set >/dev/null 2>&1 || { echo "[!] termux-clipboard-set not found. Install Termux:API app + pkg install termux-api"; exit 1; }
termux-clipboard-set < ~/offer.txt
echo "[✓] Offer copied to clipboard"
termux-open-url "https://www.reddit.com/r/forhire/submit"
termux-open-url "https://www.upwork.com/nx/find-work/best-matches"
termux-open-url "https://x.com/compose/post"
termux-open-url "https://www.indiehackers.com/products/new"
echo "[✓] Tabs opened — paste from clipboard."
