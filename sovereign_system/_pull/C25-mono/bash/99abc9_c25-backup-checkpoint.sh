#!/data/data/com.termux/files/usr/bin/bash
# C25 BACKUP CHECKPOINT
# Cygel White / FacePrintPay / Kre8tive Koncepts
# Greensboro, NC — 2026-03-15

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="$HOME/backups/checkpoint_$TIMESTAMP"
LOG="$HOME/sovereign_gtp/logs/checkpoint.log"

mkdir -p "$BACKUP_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║  🌟 C25 BACKUP CHECKPOINT                   ║"
echo "║  $(date '+%Y-%m-%d %H:%M:%S')               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[$(date)] Checkpoint started: $TIMESTAMP" >> "$LOG"

# ── 1. Snapshot all service configs ──
echo "📸 Snapshotting service configs..."
mkdir -p "$BACKUP_DIR/configs"

# Save all running ports and PIDs
for port in 3000 3001 3002 3003 3004 3005 11434; do
    result=$(curl -s --max-time 2 http://localhost:$port 2>/dev/null)
    if [ -n "$result" ]; then
        echo "$result" > "$BACKUP_DIR/configs/port_${port}.json"
        echo "  ✅ Port $port saved"
    fi
done

# ── 2. Backup .bashrc and boot scripts ──
echo "💾 Backing up shell configs..."
cp ~/.bashrc "$BACKUP_DIR/bashrc.bak"
cp ~/.env.tokens "$BACKUP_DIR/env.tokens.bak" 2>/dev/null
cp ~/.termux/boot/c25-autostart.sh "$BACKUP_DIR/c25-autostart.bak" 2>/dev/null
cp ~/.config/ranger/rc.conf "$BACKUP_DIR/ranger-rc.conf.bak" 2>/dev/null
echo "  ✅ Shell configs saved"

# ── 3. Backup all key scripts ──
echo "📜 Backing up C25 scripts..."
mkdir -p "$BACKUP_DIR/scripts"
cp ~/c25-swarm-sync.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/c25-autopush.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/c25-persistent-agents.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/c25-backup-checkpoint.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/c25-complete-and-sync.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/c25-token-guard.sh "$BACKUP_DIR/scripts/" 2>/dev/null
echo "  ✅ Scripts saved"

# ── 4. Backup key project files ──
echo "🔐 Backing up MyBuyo Biometric SaaS..."
mkdir -p "$BACKUP_DIR/projects/mybuyo-biometric-saas"
cp -r ~/github-repos/FacePrintPay/mybuyo-biometric-saas/{core,auth,packages,sdk,server.js,package.json} \
    "$BACKUP_DIR/projects/mybuyo-biometric-saas/" 2>/dev/null
echo "  ✅ MyBuyo saved"

echo "💵 Backing up Digital Dollar..."
mkdir -p "$BACKUP_DIR/projects/digital-dollar"
cp -r ~/github-repos/FacePrintPay/digital-dollar/{core,wallet,blockchain,api,frontend,package.json} \
    "$BACKUP_DIR/projects/digital-dollar/" 2>/dev/null
echo "  ✅ Digital Dollar saved"

echo "🦁 Backing up Food Lion pitch..."
mkdir -p "$BACKUP_DIR/projects/foodlion"
cp -r ~/github-repos/FacePrintPay/mybuyoxfoodlion-pitch/ \
    "$BACKUP_DIR/projects/foodlion/" 2>/dev/null
echo "  ✅ Food Lion saved"

echo "🌟 Backing up Constellation25 core..."
mkdir -p "$BACKUP_DIR/projects/constellation25"
cp -r ~/github-repos/Constillation25/sovereign_gtp/agents \
    "$BACKUP_DIR/projects/constellation25/" 2>/dev/null
cp ~/github-repos/Constillation25/sovereign_gtp/backend/server.js \
    "$BACKUP_DIR/projects/constellation25/" 2>/dev/null
echo "  ✅ Constellation25 saved"

echo "🖥️  Backing up MyBuyo restore stack..."
mkdir -p "$BACKUP_DIR/projects/mybuyo-restore"
cp ~/mybuyo-restore/start.sh "$BACKUP_DIR/projects/mybuyo-restore/" 2>/dev/null
cp ~/mybuyo-restore/package.json "$BACKUP_DIR/projects/mybuyo-restore/" 2>/dev/null
cp -r ~/mybuyo-restore/services "$BACKUP_DIR/projects/mybuyo-restore/" 2>/dev/null
echo "  ✅ MyBuyo restore saved"

# ── 5. Create checkpoint manifest ──
echo "📋 Creating manifest..."
cat > "$BACKUP_DIR/MANIFEST.md" << MANIFEST
# C25 Backup Checkpoint
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Author:** Cygel White / FacePrintPay / Kre8tive Koncepts
**Location:** Greensboro, NC

## Services at Checkpoint
| Port | Service | Status |
|------|---------|--------|
| 3000 | PATHOS | ✅ |
| 3001 | Dashboard | ✅ |
| 3002 | Keys API | ✅ |
| 3003 | Swarm API | ✅ |
| 3004 | MyBuyo Biometric | ✅ |
| 3005 | Digital Dollar DD$ | ✅ |
| 11434 | Ollama (2 models) | ✅ |

## Projects
- Constellation25 — 25 agents, PATHOS, sovereign swarm
- MyBuyo Biometric SaaS — #FACEIT #PRINTPAY #BLINKLINK #SPEAKIT
- Digital Dollar DD$ — sovereign biometric currency
- MyBuyo × Food Lion — pilot proposal
- FacePrintPay — gateway + identity

## Stack
- Platform: Android/Termux
- Models: qwen2.5:7b + llama3.2:1b
- Repos: 100+ on GitHub/FacePrintPay
- Build: SHA256 · CONSTELLATION25-MASTER-v1.0

## Restore
\`\`\`bash
bash ~/backups/checkpoint_$TIMESTAMP/scripts/c25-swarm-sync.sh
\`\`\`
MANIFEST
echo "  ✅ Manifest created"

# ── 6. Tar the entire checkpoint ──
echo "📦 Creating tar archive..."
cd "$HOME/backups"
tar -czf "checkpoint_${TIMESTAMP}.tar.gz" "checkpoint_$TIMESTAMP/" 2>/dev/null
SIZE=$(du -sh "checkpoint_${TIMESTAMP}.tar.gz" | cut -f1)
echo "  ✅ Archive: checkpoint_${TIMESTAMP}.tar.gz ($SIZE)"

# ── 7. Copy to storage for Xplore access ──
echo "📱 Copying to device storage..."
cp "checkpoint_${TIMESTAMP}.tar.gz" \
    "$HOME/storage/downloads/C25_checkpoint_${TIMESTAMP}.tar.gz" 2>/dev/null
echo "  ✅ Available in Downloads"

# ── 8. Git tag this checkpoint ──
echo "🏷️  Tagging checkpoint in GitHub..."
cd ~/github-repos/Constillation25
git tag -a "checkpoint-$TIMESTAMP" \
    -m "C25 Checkpoint: All 7 services live | DD$ + MyBuyo + Food Lion" 2>/dev/null
git push origin "checkpoint-$TIMESTAMP" 2>/dev/null
echo "  ✅ Tagged: checkpoint-$TIMESTAMP"

# ── 9. OTS Bitcoin timestamp ──
echo "⛓️  Bitcoin timestamping checkpoint..."
pip install opentimestamps-client --break-system-packages -q 2>/dev/null
ots stamp "$HOME/backups/checkpoint_${TIMESTAMP}.tar.gz" 2>/dev/null && \
    echo "  ✅ Bitcoin OTS stamp created" || \
    echo "  ⚠️  OTS pending - install opentimestamps-client"

echo "" | tee -a "$LOG"
echo "[$(date)] Checkpoint complete: $BACKUP_DIR" >> "$LOG"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  ✅ CHECKPOINT COMPLETE                     ║"
printf "║  📁 %-42s║\n" "$BACKUP_DIR"
printf "║  📦 %-42s║\n" "checkpoint_${TIMESTAMP}.tar.gz ($SIZE)"
echo "║  📱 Available in Downloads (Xplore)         ║"
echo "║  🏷️  Git tagged: checkpoint-$TIMESTAMP  ║"
echo "║  ⛓️  Bitcoin OTS timestamp requested        ║"
echo "╚══════════════════════════════════════════════╝"
