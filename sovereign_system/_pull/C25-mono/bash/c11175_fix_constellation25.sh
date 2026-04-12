#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

C25_HOME="$HOME/.constellation25"
AGENT_DIR="$C25_HOME/agents"
MODULE_DIR="$C25_HOME/modules"
STATE_DIR="$C25_HOME/state"
CONFIG_DIR="$C25_HOME/config"
LOG_DIR="$C25_HOME/logs"

echo "🔧 FIXING CONSTELLATION25 STRUCTURE..."

# Fix agents directory
if [ -f "$AGENT_DIR" ]; then
    mv "$AGENT_DIR" "$AGENT_DIR.bak"
fi
mkdir -p "$AGENT_DIR"

# Create 25 agents
for name in Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto Eris Haumea Makemake Ceres Sedna Orcus Ixion Varuna Chaos Salacia Varda Huya Quaoar Gonggong 2002AW197 Pathos-Sovereign; do
    echo '#!/data/data/com.termux/files/usr/bin/bash' > "$AGENT_DIR/${name}.sh"
    echo "echo \"[${name}] ACTIVE\"" >> "$AGENT_DIR/${name}.sh"
    chmod +x "$AGENT_DIR/${name}.sh"
done

# Create 27 modules
mkdir -p "$MODULE_DIR"
for mod in auth deploy monitor backup security network database cache api queue storage compute analytics logging metrics alerts config secrets vault proxy gateway registry scanner builder tester docs compliance audit health; do
    echo '#!/data/data/com.termux/files/usr/bin/bash' > "$MODULE_DIR/${mod}.sh"
    echo "echo \"[Module:${mod}] READY\"" >> "$MODULE_DIR/${mod}.sh"
    chmod +x "$MODULE_DIR/${mod}.sh"
done

# Create state files
mkdir -p "$STATE_DIR"
echo '{"status":"running","agents":25}' > "$STATE_DIR/swarm.state"

# Create launcher
cat > ~/c25-launch.sh << 'LAUNCHER'
#!/data/data/com.termux/files/usr/bin/bash
cd "$HOME/.constellation25"
./constellation25.sh "$@"
LAUNCHER
chmod +x ~/c25-launch.sh

echo "✅ FIXED! Run: ~/c25-launch.sh"
