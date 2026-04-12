#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Stopping mesh..."
for pid in pids/*.pid; do
    [ -f "$pid" ] && kill $(cat "$pid") 2>/dev/null
done
rm -f pids/*.pid
echo "✓ Stopped"
