#!/data/data/com.termux/files/usr/bin/bash
while true; do
  clear
  echo "🌍 SovereignGTP Task Monitor"
  echo "============================"
  echo "📥 Incoming:  $(ls tasks/incoming 2>/dev/null | wc -l)"
  echo "✅ Processed: $(ls tasks/processed 2>/dev/null | wc -l)"
  echo "📄 Outputs:   $(ls outputs 2>/dev/null | wc -l)"
  echo "🤖 Agents:    $(ls pids/*.pid 2>/dev/null | wc -l)"
  echo ""
  echo "Recent outputs:"
  ls -lt outputs 2>/dev/null | head -5
  sleep 2
done
