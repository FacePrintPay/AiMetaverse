#!/data/data/com.termux/files/usr/bin/bash
pkg update && pkg upgrade -y
pkg install python git zip unzip -y
pip install -r requirements.txt
echo "✅ Setup complete"
