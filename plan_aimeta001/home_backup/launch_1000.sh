#!/data/data/com.termux/files/usr/bin/bash

echo "🌍 SOVEREIGNGTP 1000-TASK PLANETARY BACKLOG"
echo "==========================================="
echo ""
echo "⚠️  WARNING: This will fire 1000 tasks into the mesh"
echo "    Estimated completion time: 2-4 hours"
echo ""
read -p "Are you absolutely sure? (type YES): " confirm

if [ "$confirm" != "YES" ]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "🚀 Launching planetary backlog..."
echo ""

# Send all categories to different agents
./batch_send.sh helio A_landing_page 20 0.05
./batch_send.sh vault B_compliance 20 0.05
./batch_send.sh echo C_investor_materials 20 0.05
./batch_send.sh chronos D_county_pilot 20 0.05
./batch_send.sh mercury E_marketing 20 0.05

echo ""
echo "🎯 All 500 tasks queued!"
echo "   (F-J categories ready in batches/ directory)"
echo ""
echo "Monitor: ./monitor_tasks.sh"
