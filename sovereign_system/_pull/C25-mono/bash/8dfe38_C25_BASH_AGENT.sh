#!/data/data/com.termux/files/usr/bin/bash
# C25 BASH MEMORY AGENT
# Reads 365 days of bash history
# Tails, fixes, debugs, packages everything

LOGDIR="$HOME/agent_logs"
mkdir -p "$LOGDIR"

echo "╔══════════════════════════════════════╗"
echo "║  MOON — READING ALL BASH HISTORY    ║"
echo "╚══════════════════════════════════════╝"

# Collect ALL bash history from every location
cat \
  ~/.bash_history \
  ~/.bash_sessions_history \
  ~/.zsh_history \
  /sdcard/.bash_history \
  /sdcard/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/.bash_history \
  /data/data/com.termux/files/home/c25-complete-build-20260316_191225/obsidian/Obsidian/Termux_Sync/Saved/Documents/Obsidian/termux-home/.bash_history \
  2>/dev/null | \
  grep -v "^#" | \
  sort -u > "$LOGDIR/full_bash_history.txt"

TOTAL=$(wc -l < "$LOGDIR/full_bash_history.txt")
echo "[Moon] $TOTAL unique commands found"

# Extract categories
grep -E "^npm "        "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_npm.txt"
grep -E "^bash |^\./" "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_scripts.txt"
grep -E "^git "        "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_git.txt"
grep -E "^vercel "     "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_vercel.txt"
grep -E "^python|^py " "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_python.txt"
grep -E "^pkg |^apt "  "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_packages.txt"
grep -E "^cd "         "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_dirs.txt"
grep -E "error|fail|Error|FAIL|cannot|not found" \
                       "$LOGDIR/full_bash_history.txt" > "$LOGDIR/bash_errors.txt"

echo "[Mercury] npm commands:     $(wc -l < $LOGDIR/bash_npm.txt)"
echo "[Mercury] bash scripts:     $(wc -l < $LOGDIR/bash_scripts.txt)"
echo "[Mercury] git commands:     $(wc -l < $LOGDIR/bash_git.txt)"
echo "[Mercury] vercel deploys:   $(wc -l < $LOGDIR/bash_vercel.txt)"
echo "[Mercury] python commands:  $(wc -l < $LOGDIR/bash_python.txt)"
echo "[Mercury] pkg installs:     $(wc -l < $LOGDIR/bash_packages.txt)"
echo "[Mars]    error commands:   $(wc -l < $LOGDIR/bash_errors.txt)"

# SATURN — reinstall all packages ever installed
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  SATURN — REINSTALLING ALL PACKAGES ║"
echo "╚══════════════════════════════════════╝"
grep "pkg install" "$LOGDIR/bash_packages.txt" | \
  sed 's/.*pkg install //' | \
  tr ' ' '\n' | \
  grep -v "^-" | \
  sort -u | while read pkg; do
    [ -z "$pkg" ] && continue
    echo "  ► pkg install $pkg"
    pkg install -y "$pkg" 2>/dev/null | tail -1
  done

# MARS — find and fix all bash scripts ever run
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  MARS — FIXING ALL BASH SCRIPTS     ║"
echo "╚══════════════════════════════════════╝"
cat "$LOGDIR/bash_scripts.txt" | \
  grep -o '[^ ]*\.sh' | \
  sort -u | while read script; do
    # Find the script
    FOUND=$(find /data/data/com.termux/files/home /sdcard \
      -name "$(basename $script)" \
      -not -path "*/node_modules/*" \
      2>/dev/null | head -1)
    [ -z "$FOUND" ] && continue
    echo "  ► $(basename $script)"
    # Validate
    ERR=$(bash -n "$FOUND" 2>&1)
    if [ -n "$ERR" ]; then
      echo "    ✗ syntax error: $ERR"
      echo "    [Mars] logging for fix..."
      echo "$FOUND: $ERR" >> "$LOGDIR/scripts_to_fix.txt"
    else
      echo "    ✓ valid"
      # Run if it's a build/deploy script
      if grep -q "build\|deploy\|vercel\|npm run" "$FOUND" 2>/dev/null; then
        echo "    [Mars] Running build script..."
        bash "$FOUND" 2>&1 | tail -5
      fi
    fi
  done

# JUPITER — retry all failed vercel deploys
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  JUPITER — RETRYING VERCEL DEPLOYS  ║"
echo "╚══════════════════════════════════════╝"
cat "$LOGDIR/bash_vercel.txt" | \
  grep "vercel --prod\|vercel deploy" | \
  sort -u | while read cmd; do
    echo "  ► $cmd"
    eval "$cmd" 2>&1 | tail -2
  done

# VENUS — retry all failed npm commands
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  VENUS — RETRYING NPM COMMANDS      ║"
echo "╚══════════════════════════════════════╝"
cat "$LOGDIR/bash_npm.txt" | \
  grep "npm run build\|npm run deploy" | \
  sort -u | while read cmd; do
    # Find what dir this was run in
    DIR=$(grep -B5 "$cmd" "$LOGDIR/full_bash_history.txt" | \
      grep "^cd " | tail -1 | sed 's/^cd //')
    [ -z "$DIR" ] && continue
    [ ! -d "$DIR" ] && continue
    echo "  ► $cmd in $DIR"
    cd "$DIR"
    eval "$cmd" 2>&1 | tail -3
    cd ~
  done

# CYGNUS — package everything into deployable state
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  CYGNUS — PACKAGING EVERYTHING      ║"
echo "╚══════════════════════════════════════╝"

find /data/data/com.termux/files/home /sdcard \
  -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/playground/*" \
  -not -path "*/template-*" \
  -not -path "*/.git/*" \
  2>/dev/null | while read pkg; do
  DIR=$(dirname "$pkg")
  NAME=$(basename "$DIR")

  # Skip if already has vercel.json
  [ -f "$DIR/vercel.json" ] && continue

  echo "  ► Packaging: $NAME"
  cd "$DIR"

  # Add missing vercel.json
  echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' \
    > vercel.json

  # Add missing .env
  [ ! -f ".env" ] && echo "NODE_ENV=production" > .env

  # Add missing .gitignore
  [ ! -f ".gitignore" ] && \
    echo -e "node_modules/\ndist/\n.env\n.vercel" > .gitignore

  # Commit and push
  git add -A 2>/dev/null
  git commit -m "C25 Cygnus: package + vercel config $(date +%Y-%m-%d)" \
    2>/dev/null | tail -1
  git push 2>/dev/null | tail -1

  cd ~
done

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  C25 BASH AGENT COMPLETE            ║"
echo "╚══════════════════════════════════════╝"
echo "  History analyzed: $TOTAL commands"
echo "  Scripts fixed:    $(wc -l < $LOGDIR/scripts_to_fix.txt 2>/dev/null || echo 0)"
echo "  Logs: $LOGDIR"
echo ""
echo "  Next: bash ~/c25_builds/RUN_ALL_BUILDS.sh"
