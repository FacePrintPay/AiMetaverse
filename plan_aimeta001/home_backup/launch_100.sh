#!/data/data/com.termux/files/usr/bin/bash
echo "🌍 Launching 100-task demo..."
echo ""
./batch_send.sh helio A_landing_page 5 &
./batch_send.sh vault B_compliance 5 &
./batch_send.sh echo C_investor 5 &
./batch_send.sh chronos D_county_pilot 5 &
./batch_send.sh mercury E_marketing 5 &
wait
echo ""
echo "🎯 All 100 tasks queued!"
echo "Monitor: ./monitor_tasks.sh"
