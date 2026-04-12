#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Monorepo target (change if you want)
ORG="FacePrintPay"
REPO_NAME="${REPO_NAME:-faceprintpay-monorepo}"   # override: REPO_NAME=faceprintpay bash script
VISIBILITY="${VISIBILITY:-private}"               # private|public
TARGET_SLUG="$ORG/$REPO_NAME"
REMOTE_URL="https://github.com/$TARGET_SLUG.git"

# Identity for commits
GIT_NAME="${GIT_NAME:-CyGeL}"
GIT_EMAIL="${GIT_EMAIL:-CyGeL.co@gmail.com}"

# Local monorepo workspace
ROOT="${ROOT:-$HOME/$REPO_NAME}"

log(){ printf "[%s] %s\n" "$(date +'%H:%M:%S')" "$*"; }
die(){ log "ERROR: $*"; exit 1; }

need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "Missing '$1'. Install: pkg install -y $2"; }

need_cmd git git
need_cmd gh gh
# rsync not required

log "Setting git identity..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

log "Checking GitHub auth..."
gh auth status >/dev/null 2>&1 || die "Not logged into gh. Run: gh auth login"

LOGIN="$(gh api user -q .login)"
if [ "$LOGIN" != "$ORG" ]; then
  log "Active gh login is: $LOGIN"
  die "Switch gh to org/user '$ORG' or set ORG env var."
fi
log "gh login OK: $LOGIN"

log "Ensuring repo exists: $TARGET_SLUG"
if gh repo view "$TARGET_SLUG" >/dev/null 2>&1; then
  log "Repo exists."
else
  log "Creating repo ($VISIBILITY)..."
  gh repo create "$TARGET_SLUG" --"$VISIBILITY" --confirm >/dev/null
  log "Repo created."
fi

log "Preparing local monorepo at: $ROOT"
mkdir -p "$ROOT"
cd "$ROOT"

if [ ! -d .git ]; then
  git init -b main >/dev/null
fi

# Force origin to the monorepo
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

# Standard monorepo structure
mkdir -p apps packages config docs scripts

# Sources we will import (only if they exist)
SRC_REPODEPO="$HOME/Kre8tiveKonceptz_RepoDepo"
SRC_WEB_OUT="$HOME/outputs/web/agi-kre8tive"
SRC_SWARM="$HOME/swarm_api"
SRC_KEYS_APP="$HOME/SOVEREIGN_VAULT/Z-36/ai-kre8tive-stargate/builds/code_gen/output.py"

log "Importing components (if present)..."

# Web UI
if [ -d "$SRC_WEB_OUT" ]; then
  mkdir -p apps/agentik-web
  cp -f "$SRC_WEB_OUT/index.html" apps/agentik-web/index.html 2>/dev/null || true
fi

# RepoDepo app copy (if your agi-kre8tive lives there)
if [ -d "$SRC_REPODEPO/apps/agi-kre8tive" ]; then
  mkdir -p apps/agi-kre8tive
  cp -f "$SRC_REPODEPO/apps/agi-kre8tive/index.html" apps/agi-kre8tive/index.html 2>/dev/null || true
fi

# Keys API (FastAPI output.py)
if [ -f "$SRC_KEYS_APP" ]; then
  mkdir -p apps/keys-api
  cp -f "$SRC_KEYS_APP" apps/keys-api/output.py
fi

# Swarm API
if [ -d "$SRC_SWARM" ]; then
  mkdir -p apps/swarm-api
  cp -f "$SRC_SWARM/swarm_api.py" apps/swarm-api/swarm_api.py 2>/dev/null || true
fi

# Helpful scripts from RepoDepo if they exist
if [ -d "$SRC_REPODEPO/scripts" ]; then
  mkdir -p scripts/repodepo
  cp -f "$SRC_REPODEPO/scripts/"*.sh scripts/repodepo/ 2>/dev/null || true
fi

# Root README
if [ ! -f README.md ]; then
cat > README.md <<'MD'
# FacePrintPay Monorepo

Local-first full stack for FacePrintPay / TheKre8tive / AGENTIK components.

## Structure
- apps/agentik-web        Static dashboard (served on :8765)
- apps/keys-api           FastAPI keys service (port :8000)
- apps/swarm-api          FastAPI swarm bridge (port :8001)
- scripts/                Termux-first ops scripts

## Quick run (Termux)
Serve web:
  python -m http.server 8765 --directory apps/agentik-web

Keys API:
  cd apps/keys-api && python -m uvicorn output:app --host 0.0.0.0 --port 8000 --app-dir .

Swarm API:
  cd apps/swarm-api && python -m uvicorn swarm_api:app --host 0.0.0.0 --port 8001 --app-dir .
MD
fi

# Vercel static config (optional)
if [ ! -f vercel.json ]; then
cat > vercel.json <<'JSON'
{
  "version": 2,
  "builds": [
    { "src": "apps/agentik-web/**", "use": "@vercel/static" }
  ],
  "routes": [
    { "src": "/", "dest": "/apps/agentik-web/index.html" },
    { "src": "/(.*)", "dest": "/apps/agentik-web/$1" }
  ]
}
JSON
fi

log "Committing..."
git add -A
if git diff --cached --quiet; then
  log "Nothing to commit."
else
  git commit -m "Bootstrap FacePrintPay monorepo" >/dev/null
fi

log "Pushing to GitHub..."
git push -u origin main

log "Done."
log "Repo: https://github.com/$TARGET_SLUG"
