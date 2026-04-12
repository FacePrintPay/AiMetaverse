#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Quick Start - Choose an option:"
echo ""
echo "1) Deploy all agents"
echo "2) Start dashboard"
echo "3) Check status"
echo "4) Stop all agents"
echo "5) Full restart"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1) agent-master deploy ;;
    2) cd ~/agent-dashboard && bash start-dashboard.sh ;;
    3) agent-master status ;;
    4) agent-master stop ;;
    5) agent-master restart ;;
    *) echo "Invalid choice" ;;
esac
