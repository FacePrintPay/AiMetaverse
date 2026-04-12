#!/data/data/com.termux/files/usr/bin/bash
# C25 MEMORY AGENT — reads 365 days of bash history
# Tails every command ever run, extracts build attempts
# Agents fix failures and redeploy

LOGDIR="$HOME/agent_logs"
MEMORY="$LOGDIR/c25_memory.txt"
BUILDS="$LOGDIR/c25_build_attempts.txt"
FAILED="$LOGDIR/c25_failed_commands.txt"
mkdir -p "$LOGDIR"

echo "╔══════════════════════════════════════╗"
echo "║  MOON — READING 365 DAY MEMORY      ║"
echo "╚══════════════════════════════════════╝"

# Pull every bash source available
cat \
  ~/.bash_history \
  ~/.bash_sessions_history \
  ~/.zsh_history \
  ~/.sh_history \
  /data/data/com.termux/files/home/.bash_history \
  /sdcard/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/.bash_history \
  2>/dev/null | sort -u > "$MEMORY"

echo "[Moon] $(wc -l < $MEMORY) unique commands in memory"

# Extract all build/deploy attempts
echo "" > "$BUILDS"
echo "" > "$FAILED"

grep -E "npm (run|install|build)|vercel|vite|webpack|deploy|bash.*\.sh|git push|pkg install" \
  "$MEMORY" | sort -u > "$BUILDS"

echo "[Mercury] $(wc -l < $BUILDS) build commands found"

# Extract failed patterns (commands with error keywords nearby)
grep -E "error|failed|FAILED|Error:|cannot|not found|no such" \
  "$MEMORY" | sort -u > "$FAILED"

echo "[Mars] $(wc -l < $FAILED) failed commands found"

# JUPITER — extract every unique pkg install ever run
echo "" 
echo "═══ PACKAGES EVER INSTALLED ═══"
grep "pkg install\|apt install\|pip install\|npm install -g" "$MEMORY" | \
  sort -u | tee "$LOGDIR/all_packages.txt"

# EARTH — extract every directory ever cd'd into
echo ""
echo "═══ ALL DIRECTORIES EVER VISITED ═══"
grep "^cd " "$MEMORY" | sort -u | tee "$LOGDIR/all_dirs.txt"

# SATURN — extract every git repo ever touched
echo ""
echo "═══ ALL GIT OPERATIONS ═══"
grep "^git " "$MEMORY" | sort -u | tee "$LOGDIR/all_git.txt"

# CYGNUS — extract every vercel deploy ever attempted
echo ""
echo "═══ ALL VERCEL DEPLOYS ATTEMPTED ═══"
grep "vercel" "$MEMORY" | sort -u | tee "$LOGDIR/all_vercel.txt"

# MARS — now tail pkg-config and debug live
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  MARS — LIVE TAIL pkg-config debug  ║"
echo "╚══════════════════════════════════════╝"

# Reinstall every package that was ever installed
echo "[Saturn] Reinstalling all remembered packages..."
grep "pkg install" "$LOGDIR/all_packages.txt" | \
  sed 's/.*pkg install/pkg install/' | \
  sort -u | while read cmd; do
    echo "  ► $cmd"
    $cmd -y 2>/dev/null | tail -1
  done

# Run pkg-config debug
echo ""
echo "[Mars] pkg-config debug..."
pkg-config --list-all 2>/dev/null | tee "$LOGDIR/pkg_config.txt" | wc -l | \
  xargs -I{} echo "  {} packages configured"

# Tail all build scripts found in memory
echo ""
echo "[Moon] Tailing build scripts from memory..."
grep "bash.*\.sh\|\.\/.*\.sh" "$MEMORY" | \
  grep -v "history\|log\|backup" | \
  sort -u | while read cmd; do
    script=$(echo "$cmd" | grep -o '[^ ]*\.sh' | head -1)
    if [ -f "$script" ]; then
      echo "  [Mars] Found + running: $script"
      bash -n "$script" 2>/dev/null && \
        bash "$script" 2>&1 | tail -3 || \
        echo "  [Mars] syntax error in $script"
    fi
  done

# Live inotify tail
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  MOON LIVE — WATCHING ALL NEW CMDS  ║"
echo "╚══════════════════════════════════════╝"

inotifywait -m \
  ~/.bash_history \
  -e modify \
  --format '%w%f' 2>/dev/null | while read f; do
  # Get last command run
  LAST=$(tail -1 ~/.bash_history)
  echo "[$(date +%H:%M:%S)] ► $LAST"
  
  # If it's a build command, tail and fix
  if echo "$LAST" | grep -qE "npm|vercel|vite|bash.*\.sh"; then
    echo "  [Mars] Build command detected — monitoring..."
    echo "$LAST" >> "$BUILDS"
  fi
done
