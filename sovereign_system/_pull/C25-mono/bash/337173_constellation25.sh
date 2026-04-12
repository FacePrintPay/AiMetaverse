#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
C25="$HOME/.constellation25"
echo "╔══════════════════════════════════════════════════╗"
echo "║       CONSTELLATION 25 - PLANETARY SWARM         ║"
echo "╚══════════════════════════════════════════════════╝"
echo "💬 Type: backup | security | status | network | exit"
echo ""
while true; do
  echo -n "🌌 C25> "
  read cmd
  case "$cmd" in
    exit|quit|q) echo "Goodbye! 🌌"; break ;;
    *backup*|*save*) echo "🤖 [Saturn]"; tar -czf "$C25/backup/c25_$(date +%Y%m%d_%H%M%S).tar.gz" "$C25/agents/" 2>/dev/null && echo "✅ Backup saved" || echo "❌ Failed" ;;
    *security*|*scan*) echo "🤖 [Venus]"; find "$C25" -type f -perm 777 2>/dev/null | head -5; echo "✅ Scan complete" ;;
    *status*|*info*) echo "🤖 [Earth]"; echo "Storage: $(du -sh "$C25" 2>/dev/null | cut -f1)"; echo "Files: $(find "$C25" -type f 2>/dev/null | wc -l)" ;;
    *network*|*ping*) echo "🤖 [Uranus]"; ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "✅ Online" || echo "❌ Offline" ;;
    *list*) echo "Agents: backup security status network list exit" ;;
    *help*) echo "Type: backup, security, status, network, list, exit" ;;
    "") continue ;;
    *) echo "🤔 Try: backup, security, status, network, exit" ;;
  esac
done
