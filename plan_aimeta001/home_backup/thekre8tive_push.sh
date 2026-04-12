#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_SLUG="FacePrintPay/TheKre8tive"
REMOTE_URL="https://github.com/${REPO_SLUG}.git"
ROOT="$HOME/TheKre8tive"

log(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
die(){ log "ERROR: $*"; exit 1; }

need_bin(){
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1 (install with: pkg install $1)"
}

need_bin git
need_bin curl

if command -v gh >/dev/null 2>&1; then
  : # ok
else
  log "Note: gh not found. If push fails, run: pkg install gh && gh auth login"
fi

mkdir -p "$ROOT"
cd "$ROOT"

if [ ! -d .git ]; then
  log "Initializing repo at $ROOT"
  git init
fi

git checkout -B main >/dev/null 2>&1 || true

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL" || true
else
  git remote add origin "$REMOTE_URL"
fi

log "Creating directories"
mkdir -p docs src/api src/orchestrator src/agents src/monitoring src/web config tests

log "Writing README.md"
cat > README.md <<'MD'
# TheKre8tive

Local-first agent orchestration stack for Termux/Linux.

Quick start:
- Install: curl -fsSL https://raw.githubusercontent.com/FacePrintPay/TheKre8tive/main/install.sh | bash
- Run: thekre8tive up
- UI: http://127.0.0.1:8765/index.html
MD

log "Writing LICENSE"
cat > LICENSE <<'LICENSE'
Copyright (c) 2025 FacePrintPay / TheKre8tive
All rights reserved. Proprietary software.
LICENSE

log "Writing .gitignore"
cat > .gitignore <<'GI'
*.log
.pids/
__pycache__/
*.pyc
.env
.DS_Store
GI

log "Writing install.sh"
cat > install.sh <<'INSTALL'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

need(){
  local bin="$1" pkgname="$2"
  if ! command -v "$bin" >/dev/null 2>&1; then
    if command -v pkg >/dev/null 2>&1; then
      pkg install -y "$pkgname" >/dev/null 2>&1
    else
      echo "Missing dependency: $bin" >&2
      exit 1
    fi
  fi
}

need git git
need python python
need curl curl

mkdir -p "$HOME/bin"
cp -f "$(dirname "$0")/thekre8tive" "$HOME/bin/thekre8tive"
chmod +x "$HOME/bin/thekre8tive"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/bin"; then
  export PATH="$HOME/bin:$PATH"
  if [ -f "$HOME/.bashrc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc"
  fi
fi

echo "Installed: thekre8tive"
INSTALL
chmod +x install.sh

log "Writing thekre8tive CLI"
cat > thekre8tive <<'CLI'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

STACK="$HOME/full_stack_integration.sh"

usage(){
  cat <<EOF
Usage: thekre8tive {up|down|restart|status|logs}

Expected control script:
  $STACK

If missing, create it and make it executable.
EOF
}

cmd="${1:-help}"
case "$cmd" in
  up|down|restart|status|logs)
    [ -x "$STACK" ] || { echo "Missing: $STACK" >&2; exit 1; }
    bash "$STACK" "$cmd"
    ;;
  *)
    usage
    ;;
esac
CLI
chmod +x thekre8tive

log "Writing static web placeholder"
cat > src/web/index.html <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>TheKre8tive</title>
</head>
<body style="font-family:sans-serif;padding:24px">
  <h1>TheKre8tive</h1>
  <p>Dashboard placeholder. Point this to your generated outputs/web/agi-kre8tive/index.html or build a proper UI here.</p>
</body>
</html>
HTML

log "Optional: Vercel static config"
cat > vercel.json <<'VJSON'
{
  "cleanUrls": true,
  "trailingSlash": false,
  "routes": [
    { "src": "/", "dest": "/src/web/index.html" },
    { "src": "/(.*)", "dest": "/src/web/$1" }
  ]
}
VJSON

git add -A
if ! git diff --cached --quiet; then
  git commit -m "Initialize TheKre8tive scaffold" || true
fi

log "Pushing to $REPO_SLUG"
if git push -u origin main; then
  log "Push complete"
else
  if command -v gh >/dev/null 2>&1; then
    log "Push failed via git HTTPS. Retrying with gh auth..."
    gh auth status >/dev/null 2>&1 || gh auth login
    git push -u origin main
    log "Push complete"
  else
    die "Push failed. Install GitHub CLI: pkg install gh && gh auth login"
  fi
fi

log "Done: https://github.com/$REPO_SLUG"
