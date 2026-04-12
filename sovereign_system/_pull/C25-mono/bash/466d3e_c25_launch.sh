#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  CONSTELLATION-25 · TERMUX BOOTSTRAP & LAUNCH SCRIPT
#  Author  : Cygel White
#  System  : C25 Sovereign Multi-Agent AI Swarm
#  Platform: Termux / Android
#  Usage   : bash c25_launch.sh
# ═══════════════════════════════════════════════════════════════════

# ── COLORS ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# ── CONFIG ───────────────────────────────────────────────────────────
C25_HOME="$HOME/pathos"
LOG_DIR="$HOME/agent_logs"
BACKUP_DIR="/sdcard/c25_backup"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3}"
NODE_MIN_VERSION=18

# ── AGENTS ───────────────────────────────────────────────────────────
AGENTS=(
  "1:Earth:Base Ops / Data"
  "2:Moon:Memory / Review"
  "3:Sun:Core Processing"
  "4:Mercury:Fast Routing"
  "5:Venus:Creative / UI-UX"
  "6:Mars:Engineering / Deploy"
  "7:Jupiter:Orchestration"
  "8:Saturn:Scheduling"
  "9:Uranus:Async Tasks"
  "10:Neptune:Deep Analysis"
  "11:Cygnus:Cross-Agent Coord"
  "12:Orion:Pattern Recognition"
  "13:Andromeda:Scale Planning"
  "14:Pleiades:Cluster Tasks"
  "15:Sirius:Priority Dispatch"
  "16:CanisMajor:Guard / Security"
  "17:Hydra:Multi-thread Ops"
)

# ── BANNER ───────────────────────────────────────────────────────────
print_banner() {
  clear
  echo -e "${CYAN}"
  echo "  ╔═══════════════════════════════════════════════════════╗"
  echo "  ║         🌌  CONSTELLATION-25  ·  C25  🌌              ║"
  echo "  ║      Sovereign Multi-Agent AI Swarm · Termux          ║"
  echo "  ║              by Cygel White                           ║"
  echo "  ╚═══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "  ${DIM}Platform : Termux / Android (offline-first)${RESET}"
  echo -e "  ${DIM}Agents   : ${#AGENTS[@]} sovereign agents${RESET}"
  echo -e "  ${DIM}Logs     : $LOG_DIR${RESET}"
  echo -e "  ${DIM}Home     : $C25_HOME${RESET}"
  echo ""
}

# ── LOGGING ──────────────────────────────────────────────────────────
log_info()    { echo -e "  ${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "  ${YELLOW}[!]${RESET} $1"; }
log_error()   { echo -e "  ${RED}[✗]${RESET} $1"; }
log_step()    { echo -e "\n  ${CYAN}${BOLD}── $1${RESET}"; }
log_agent()   { echo -e "  ${MAGENTA}[🌌]${RESET} $1"; }
log_pathos()  { echo -e "  ${BLUE}[⚡]${RESET} $1"; }

# ── STEP 1: TERMUX PACKAGES ───────────────────────────────────────────
setup_packages() {
  log_step "STEP 1 · Termux Package Dependencies"

  # Update repos once
  log_info "Updating package repos..."
  pkg update -y -q 2>/dev/null || log_warn "pkg update had warnings — continuing"

  PACKAGES=(nodejs git curl wget python jq)
  for pkg in "${PACKAGES[@]}"; do
    if command -v "$pkg" &>/dev/null || dpkg -l "$pkg" &>/dev/null 2>&1; then
      log_info "$pkg already installed"
    else
      log_warn "Installing $pkg..."
      pkg install -y "$pkg" -q 2>/dev/null && log_info "$pkg installed" || log_error "Failed to install $pkg"
    fi
  done

  # Node version check
  if command -v node &>/dev/null; then
    NODE_VER=$(node -e "process.stdout.write(process.version.slice(1).split('.')[0])")
    if [ "$NODE_VER" -ge "$NODE_MIN_VERSION" ]; then
      log_info "Node.js v$(node -v | tr -d 'v') — OK"
    else
      log_warn "Node.js v$NODE_VER detected — recommend v$NODE_MIN_VERSION+"
    fi
  else
    log_error "Node.js not found after install attempt"
  fi

  # npm global prefix for Termux
  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global" 2>/dev/null
  export PATH="$HOME/.npm-global/bin:$PATH"
}

# ── STEP 2: AGENT LOG DIRECTORIES ────────────────────────────────────
setup_log_dirs() {
  log_step "STEP 2 · Agent Log Directories"

  mkdir -p "$LOG_DIR"
  log_info "Log directory: $LOG_DIR"

  for entry in "${AGENTS[@]}"; do
    IFS=':' read -r id name role <<< "$entry"
    LOG_FILE="$LOG_DIR/agent_${id}_${name}.log"
    if [ ! -f "$LOG_FILE" ]; then
      {
        echo "═══════════════════════════════════════════════════"
        echo "  AGENT $id · $name"
        echo "  ROLE  : $role"
        echo "  SYSTEM: Constellation-25 · Sovereign Swarm"
        echo "  INIT  : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "═══════════════════════════════════════════════════"
        echo ""
        echo "[$(date '+%H:%M:%S')] [SYSTEM] Agent $name initialized. Status: IDLE"
      } > "$LOG_FILE"
      log_agent "Created log → agent_${id}_${name}.log"
    else
      log_info "Log exists → agent_${id}_${name}.log"
      # Append boot entry
      echo "[$(date '+%H:%M:%S')] [SYSTEM] Agent $name rebooted. C25 launch script v$(date '+%Y%m%d')" >> "$LOG_FILE"
    fi
  done

  # Master swarm log
  SWARM_LOG="$LOG_DIR/swarm_master.log"
  {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PATHOS] C25 launch script executed"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PATHOS] ${#AGENTS[@]} agents initialized"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PATHOS] Platform: Termux/Android · Model: $OLLAMA_MODEL"
  } >> "$SWARM_LOG"

  log_info "Master log → swarm_master.log"
  echo ""
  log_info "All ${#AGENTS[@]} agent logs ready"
}

# ── STEP 3: OLLAMA ────────────────────────────────────────────────────
setup_ollama() {
  log_step "STEP 3 · Ollama Local Model (Free · Offline)"

  if command -v ollama &>/dev/null; then
    log_info "Ollama already installed — $(ollama --version 2>/dev/null || echo 'version unknown')"
  else
    log_warn "Ollama not found. Attempting install..."
    echo ""
    echo -e "  ${DIM}Ollama requires ARM64 Android device.${RESET}"
    echo -e "  ${DIM}Installing via curl...${RESET}"
    echo ""

    if curl -fsSL https://ollama.com/install.sh | sh 2>/dev/null; then
      log_info "Ollama installed successfully"
    else
      log_warn "Auto-install failed. Manual steps:"
      echo ""
      echo -e "  ${YELLOW}Option A (recommended):${RESET}"
      echo -e "  ${DIM}1. Install Ollama APK from https://ollama.com/download/android${RESET}"
      echo -e "  ${DIM}2. Open Ollama app → it runs as background service${RESET}"
      echo -e "  ${DIM}3. Re-run this script${RESET}"
      echo ""
      echo -e "  ${YELLOW}Option B (Termux):${RESET}"
      echo -e "  ${DIM}pkg install ollama${RESET}"
      echo ""
      log_warn "Skipping Ollama model pull — swarm will use Anthropic only"
      return 0
    fi
  fi

  # Start Ollama server if not running
  if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
    log_warn "Ollama server not running — starting..."
    ollama serve &>/dev/null &
    OLLAMA_PID=$!
    sleep 3
    if curl -s http://localhost:11434/api/tags &>/dev/null; then
      log_info "Ollama server started (PID: $OLLAMA_PID)"
    else
      log_warn "Ollama server may need more time to start"
    fi
  else
    log_info "Ollama server already running at localhost:11434"
  fi

  # Check if model is pulled
  if ollama list 2>/dev/null | grep -q "$OLLAMA_MODEL"; then
    log_info "Model '$OLLAMA_MODEL' already pulled"
  else
    log_warn "Model '$OLLAMA_MODEL' not found — pulling now..."
    echo -e "  ${DIM}This may take several minutes on first run...${RESET}"
    echo ""
    if ollama pull "$OLLAMA_MODEL"; then
      log_info "Model '$OLLAMA_MODEL' pulled successfully"
    else
      log_error "Failed to pull '$OLLAMA_MODEL'"
      echo ""
      echo -e "  ${YELLOW}Available lightweight models for Android:${RESET}"
      echo -e "  ${DIM}ollama pull phi3        (3.8B — fastest)${RESET}"
      echo -e "  ${DIM}ollama pull mistral     (7B — balanced)${RESET}"
      echo -e "  ${DIM}ollama pull llama3      (8B — recommended)${RESET}"
      echo -e "  ${DIM}ollama pull tinyllama   (1.1B — minimal RAM)${RESET}"
      echo ""
      echo -e "  ${DIM}To change model: OLLAMA_MODEL=phi3 bash c25_launch.sh${RESET}"
    fi
  fi

  # Test model
  log_info "Testing Ollama inference..."
  TEST_RESPONSE=$(curl -s http://localhost:11434/api/chat \
    -d "{\"model\":\"$OLLAMA_MODEL\",\"stream\":false,\"messages\":[{\"role\":\"user\",\"content\":\"Reply with one word: online\"}]}" \
    2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message',{}).get('content',''))" 2>/dev/null)

  if [ -n "$TEST_RESPONSE" ]; then
    log_info "Ollama inference OK — response: \"$TEST_RESPONSE\""
  else
    log_warn "Ollama test inference silent — model may still be loading"
  fi
}

# ── STEP 4: C25 PATHOS SETUP ─────────────────────────────────────────
setup_pathos() {
  log_step "STEP 4 · C25 Pathos Orchestrator Setup"

  # Create pathos directory if missing
  if [ ! -d "$C25_HOME" ]; then
    log_warn "Pathos directory not found at $C25_HOME — creating..."
    mkdir -p "$C25_HOME"

    # Create minimal package.json
    cat > "$C25_HOME/package.json" << 'EOF'
{
  "name": "constellation-25",
  "version": "2.5.0",
  "description": "C25 Sovereign Multi-Agent AI Swarm Orchestrator",
  "main": "server.js",
  "author": "Cygel White",
  "license": "MIT",
  "scripts": {
    "start": "node server.js",
    "agents": "tail -f ~/agent_logs/agent_$1_*.log"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

    # Create minimal server.js stub if missing
    if [ ! -f "$C25_HOME/server.js" ]; then
      cat > "$C25_HOME/server.js" << 'SERVEREOF'
// ═══════════════════════════════════════════════════════
//  CONSTELLATION-25 · PATHOS ORCHESTRATOR
//  Sovereign Multi-Agent AI Swarm
//  Author: Cygel White
// ═══════════════════════════════════════════════════════
const express = require('express');
const fs      = require('fs');
const path    = require('path');
const app     = express();
const PORT    = process.env.PORT || 3000;
const LOG_DIR = path.join(process.env.HOME, 'agent_logs');

app.use(express.json());

const AGENTS = [
  { id:1,  name:'Earth',      role:'Base Ops / Data',       status:'active' },
  { id:2,  name:'Moon',       role:'Memory / Review',        status:'active' },
  { id:3,  name:'Sun',        role:'Core Processing',        status:'active' },
  { id:4,  name:'Mercury',    role:'Fast Routing',           status:'active' },
  { id:5,  name:'Venus',      role:'Creative / UI-UX',       status:'active' },
  { id:6,  name:'Mars',       role:'Engineering / Deploy',   status:'active' },
  { id:7,  name:'Jupiter',    role:'Orchestration',          status:'active' },
  { id:8,  name:'Saturn',     role:'Scheduling',             status:'idle'   },
  { id:9,  name:'Uranus',     role:'Async Tasks',            status:'idle'   },
  { id:10, name:'Neptune',    role:'Deep Analysis',          status:'active' },
  { id:11, name:'Cygnus',     role:'Cross-Agent Coord',      status:'idle'   },
  { id:12, name:'Orion',      role:'Pattern Recognition',    status:'active' },
  { id:13, name:'Andromeda',  role:'Scale Planning',         status:'idle'   },
  { id:14, name:'Pleiades',   role:'Cluster Tasks',          status:'idle'   },
  { id:15, name:'Sirius',     role:'Priority Dispatch',      status:'active' },
  { id:16, name:'CanisMajor', role:'Guard / Security',       status:'active' },
  { id:17, name:'Hydra',      role:'Multi-thread Ops',       status:'idle'   },
];

function logAgent(id, name, message) {
  const time = new Date().toISOString();
  const line = `[${time}] [${name.toUpperCase()}] ${message}\n`;
  const file = path.join(LOG_DIR, `agent_${id}_${name}.log`);
  fs.appendFileSync(file, line);
  console.log(`🌌 ${name}: ${message}`);
}

// Routes
app.get('/',           (req, res) => res.json({ system:'Constellation-25', status:'online', agents:AGENTS.length, uptime:process.uptime() }));
app.get('/agents',     (req, res) => res.json(AGENTS));
app.get('/health',     (req, res) => res.json({ status:'ok', time:new Date().toISOString() }));
app.get('/logs/:name', (req, res) => {
  const f = path.join(LOG_DIR, `agent_${req.params.name}.log`);
  res.json({ log: fs.existsSync(f) ? fs.readFileSync(f,'utf8').split('\n').slice(-50) : ['No log found'] });
});

app.post('/dispatch', (req, res) => {
  const { agent_id, task } = req.body;
  const agent = AGENTS.find(a => a.id === agent_id) || AGENTS[6]; // default Jupiter
  logAgent(agent.id, agent.name, `Task received: ${task}`);
  res.json({ status:'dispatched', agent:agent.name, task, time:new Date().toISOString() });
});

app.post('/toggle/:id', (req, res) => {
  const agent = AGENTS.find(a => a.id === parseInt(req.params.id));
  if (!agent) return res.status(404).json({ error:'Agent not found' });
  agent.status = agent.status === 'active' ? 'idle' : 'active';
  logAgent(agent.id, agent.name, `Status toggled → ${agent.status.toUpperCase()}`);
  res.json({ agent:agent.name, status:agent.status });
});

// Boot
app.listen(PORT, () => {
  console.log('\n  ╔══════════════════════════════════════════╗');
  console.log('  ║  🌌 CONSTELLATION-25 · PATHOS ONLINE     ║');
  console.log(`  ║  Port : ${PORT}                              ║`);
  console.log(`  ║  Agents: ${AGENTS.length} initialized                  ║`);
  console.log('  ╚══════════════════════════════════════════╝\n');
  AGENTS.forEach(a => logAgent(a.id, a.name, `Initialized. Role: ${a.role}. Status: ${a.status.toUpperCase()}`));
  console.log(`\n  Logs: ${LOG_DIR}`);
  console.log('  API:  http://localhost:3000\n');
});
SERVEREOF
      log_info "Created server.js stub — replace with your full orchestrator"
    fi

    # Install dependencies
    log_warn "Installing Node.js dependencies..."
    cd "$C25_HOME" && npm install --silent 2>/dev/null && log_info "Dependencies installed" || log_warn "npm install had warnings"
  else
    log_info "Pathos directory found: $C25_HOME"

    # Install deps if node_modules missing
    if [ ! -d "$C25_HOME/node_modules" ]; then
      log_warn "node_modules missing — running npm install..."
      cd "$C25_HOME" && npm install --silent 2>/dev/null
    else
      log_info "node_modules present"
    fi
  fi

  # Set up shell aliases
  setup_aliases
}

# ── STEP 5: SHELL ALIASES ─────────────────────────────────────────────
setup_aliases() {
  log_step "STEP 5 · Shell Aliases"

  BASHRC="$HOME/.bashrc"
  MARKER="# ── C25 CONSTELLATION-25 ALIASES ──"

  if grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
    log_info "C25 aliases already in .bashrc"
  else
    cat >> "$BASHRC" << ALIASEOF

$MARKER
alias pathos='cd $HOME/pathos && node server.js'
alias agents='tail -f $HOME/agent_logs/agent_\$1_*.log 2>/dev/null || ls $HOME/agent_logs/'
alias agents-all='tail -n 20 $HOME/agent_logs/agent_*.log'
alias sync-agents='cp -r $HOME/agent_logs /sdcard/c25_backup/logs_\$(date +%Y%m%d_%H%M%S) && echo "✓ Logs backed up to SD card"'
alias c25-status='curl -s http://localhost:3000/agents | python3 -m json.tool 2>/dev/null || echo "Pathos not running — type: pathos"'
alias c25-log='cat $HOME/agent_logs/swarm_master.log | tail -30'
alias c25-health='curl -s http://localhost:3000/health'
alias c25='bash $HOME/c25_launch.sh'
export PATH="\$HOME/.npm-global/bin:\$PATH"
# ── END C25 ──
ALIASEOF
    log_info "C25 aliases added to .bashrc"
    echo ""
    echo -e "  ${DIM}Available commands after restart:${RESET}"
    echo -e "  ${GREEN}pathos${RESET}       — start the C25 orchestrator"
    echo -e "  ${GREEN}agents${RESET}       — view agent logs"
    echo -e "  ${GREEN}agents-all${RESET}   — tail all agent logs"
    echo -e "  ${GREEN}sync-agents${RESET}  — backup logs to SD card"
    echo -e "  ${GREEN}c25-status${RESET}   — check all agent statuses"
    echo -e "  ${GREEN}c25-log${RESET}      — view master swarm log"
    echo -e "  ${GREEN}c25${RESET}          — re-run this setup script"
  fi
}

# ── STEP 6: SD CARD BACKUP ────────────────────────────────────────────
setup_backup() {
  log_step "STEP 6 · SD Card Backup"

  if [ -d "/sdcard" ]; then
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/logs"
    mkdir -p "$BACKUP_DIR/pathos"

    # Backup logs
    if cp -r "$LOG_DIR/." "$BACKUP_DIR/logs/" 2>/dev/null; then
      log_info "Agent logs backed up → $BACKUP_DIR/logs/"
    else
      log_warn "Log backup failed — check Termux storage permissions"
      echo -e "  ${DIM}Fix: termux-setup-storage then re-run${RESET}"
    fi

    # Backup pathos config (not node_modules)
    if [ -f "$C25_HOME/package.json" ]; then
      cp "$C25_HOME/package.json" "$BACKUP_DIR/pathos/" 2>/dev/null
      cp "$C25_HOME/server.js"    "$BACKUP_DIR/pathos/" 2>/dev/null
      log_info "Pathos config backed up → $BACKUP_DIR/pathos/"
    fi

    # Write backup manifest
    {
      echo "C25 BACKUP MANIFEST"
      echo "Date    : $(date '+%Y-%m-%d %H:%M:%S')"
      echo "Agents  : ${#AGENTS[@]}"
      echo "Model   : $OLLAMA_MODEL"
      echo "Source  : $HOME"
    } > "$BACKUP_DIR/MANIFEST.txt"

    log_info "Backup manifest written"
  else
    log_warn "/sdcard not accessible"
    echo -e "  ${DIM}Run: termux-setup-storage to grant SD card access${RESET}"
  fi
}

# ── STEP 7: LAUNCH PATHOS ─────────────────────────────────────────────
launch_pathos() {
  log_step "STEP 7 · Launching Pathos Orchestrator"

  if ! command -v node &>/dev/null; then
    log_error "Node.js not available — cannot launch Pathos"
    return 1
  fi

  if [ ! -f "$C25_HOME/server.js" ]; then
    log_error "server.js not found at $C25_HOME"
    return 1
  fi

  # Check if already running
  if curl -s http://localhost:3000/health &>/dev/null; then
    log_info "Pathos already running at http://localhost:3000"
    log_pathos "$(curl -s http://localhost:3000/ | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Agents: {d[\"agents\"]} | Uptime: {d[\"uptime\"]:.0f}s')" 2>/dev/null)"
    return 0
  fi

  # Print final swarm status before launch
  echo ""
  echo -e "  ${CYAN}╔═══════════════════════════════════════════╗${RESET}"
  echo -e "  ${CYAN}║   🌌 C25 AGENT SWARM — PRE-LAUNCH STATUS  ║${RESET}"
  echo -e "  ${CYAN}╚═══════════════════════════════════════════╝${RESET}"
  echo ""
  for entry in "${AGENTS[@]}"; do
    IFS=':' read -r id name role <<< "$entry"
    LOG_FILE="$LOG_DIR/agent_${id}_${name}.log"
    if [ -f "$LOG_FILE" ]; then
      echo -e "  ${GREEN}●${RESET} ${BOLD}${name}${RESET}${DIM} (${role})${RESET}"
    else
      echo -e "  ${RED}○${RESET} ${name} ${DIM}(log missing)${RESET}"
    fi
  done
  echo ""

  log_pathos "Starting Pathos orchestrator..."
  echo -e "  ${DIM}cd $C25_HOME && node server.js${RESET}"
  echo ""

  # Launch
  cd "$C25_HOME" && node server.js
}

# ── MAIN ──────────────────────────────────────────────────────────────
main() {
  print_banner

  # Parse args
  SKIP_OLLAMA=false
  SKIP_BACKUP=false
  LAUNCH_ONLY=false

  for arg in "$@"; do
    case $arg in
      --no-ollama)   SKIP_OLLAMA=true ;;
      --no-backup)   SKIP_BACKUP=true ;;
      --launch-only) LAUNCH_ONLY=true ;;
      --help|-h)
        echo "Usage: bash c25_launch.sh [options]"
        echo ""
        echo "Options:"
        echo "  --no-ollama    Skip Ollama install/check"
        echo "  --no-backup    Skip SD card backup"
        echo "  --launch-only  Skip setup, just launch Pathos"
        echo ""
        echo "Env vars:"
        echo "  OLLAMA_MODEL=phi3  Use a different local model"
        exit 0
        ;;
    esac
  done

  if [ "$LAUNCH_ONLY" = true ]; then
    launch_pathos
    exit 0
  fi

  setup_packages
  setup_log_dirs
  [ "$SKIP_OLLAMA" = false ] && setup_ollama
  setup_pathos
  [ "$SKIP_BACKUP" = false ] && setup_backup

  echo ""
  echo -e "  ${GREEN}${BOLD}╔═══════════════════════════════════════════╗${RESET}"
  echo -e "  ${GREEN}${BOLD}║   ✓  C25 SETUP COMPLETE                   ║${RESET}"
  echo -e "  ${GREEN}${BOLD}╚═══════════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "  ${WHITE}Reload aliases:${RESET}  ${CYAN}source ~/.bashrc${RESET}"
  echo -e "  ${WHITE}Start swarm:${RESET}     ${CYAN}pathos${RESET}"
  echo -e "  ${WHITE}View logs:${RESET}       ${CYAN}agents${RESET}"
  echo -e "  ${WHITE}Backup:${RESET}          ${CYAN}sync-agents${RESET}"
  echo -e "  ${WHITE}Status:${RESET}          ${CYAN}c25-status${RESET}"
  echo ""
  echo -e "  ${DIM}Launching Pathos in 3 seconds... (Ctrl+C to cancel)${RESET}"
  sleep 3

  launch_pathos
}

main "$@"
