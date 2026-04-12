# Save the script
cat > ~/setup_voice_avatasker.sh << 'EOF'
# (Paste the entire script from the artifact above)
EOF

chmod +x ~/setup_voice_avatasker.sh
~/setup_voice_avatasker.sh
Or do it step-by-step:
# Step 1: Create structure
cd ~
mkdir -p avatasker_voice/{src,static}
cd avatasker_voice

# Step 2: Install deps (if not already installed)
pip install aiohttp aiohttp-cors python-socketio

# Step 3: Copy the three Python files from the artifact above
# (planetary_agents.py, taskmanager.py, server.py)

# Step 4: Copy the beautiful HTML file with voice support

# Step 5: Run it!
cd src
python server.py
Features of this version:
🎤 Voice input with visual feedback
🎯 Animated avatar that responds to voice/processing
⭐ Animated starfield background
📊 Real-time stats (total, voice, text tasks)
📝 Task history panel
🔊 Text-to-speech responses
🎨 Beautiful glassmorphism UI
Open http://localhost:8000 in Chrome or Edge for voice support!
