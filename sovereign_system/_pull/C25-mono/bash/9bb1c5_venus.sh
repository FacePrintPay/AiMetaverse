#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"; LOGS="$C25/logs"; NAME="venus"
UI="$C25/ui"
mkdir -p "$UI"
while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  # Generate status dashboard HTML
  cat > "$UI/dashboard.html" << HTML
<!DOCTYPE html><html><head><title>C25 Dashboard</title>
<style>body{background:#0a0a1a;color:#00ff88;font-family:monospace;padding:20px}
h1{color:#7f5af0}.agent{display:inline-block;padding:4px 8px;margin:2px;
border:1px solid #00ff88;border-radius:4px;font-size:11px}</style></head>
<body><h1>🌌 CONSTELLATION25</h1>
<p>Updated: $TS</p>
<div id="agents">
$(for A in earth mercury venus mars jupiter saturn uranus neptune pluto luna \
  sol sirius vega rigel pleiades orion hydra lyra cygnus andromeda \
  perseus cassiopeia aquila draco fomalhaut; do
  echo "<span class='agent'>$A</span>"
done)
</div>
<p>Log entries: $(wc -l < "$LOGS/constellation25.log" 2>/dev/null || echo 0)</p>
</body></html>
HTML
  echo "[$TS] [$NAME] DASHBOARD_UPDATED $UI/dashboard.html" >> "$LOGS/constellation25.log"
  echo "[$TS] [$NAME] STATUS:OK" >> "$LOGS/venus.log"
  sleep 120
done
