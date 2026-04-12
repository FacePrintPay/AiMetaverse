#!/usr/bin/env bash
set -euo pipefail

# ---- Config (override via env if you want) ----
REPO_DIR="${REPO_DIR:-$HOME/sovereignGTP-fullstack}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
VENV_DIR="${VENV_DIR:-$REPO_DIR/.venv_termux_api}"

echo "🧨 onebasher: FastAPI launcher (Termux-safe)"
echo "📦 repo: $REPO_DIR"
echo "🌐 host: $HOST  port: $PORT"

[ -d "$REPO_DIR" ] || { echo "❌ Repo not found: $REPO_DIR"; exit 1; }
cd "$REPO_DIR"

# Must be in repo root that contains backend/
[ -d "backend" ] || { echo "❌ No ./backend directory here. PWD=$(pwd)"; ls -la; exit 1; }
[ -f "backend/main.py" ] || { echo "❌ Missing backend/main.py"; ls -la backend; exit 1; }

# Make backend importable as a package
[ -f "backend/__init__.py" ] || touch "backend/__init__.py"

# Create venv if missing
if [ ! -x "$VENV_DIR/bin/python" ]; then
  echo "🧪 Creating venv: $VENV_DIR"
  rm -rf "$VENV_DIR"
  python -m venv "$VENV_DIR"
fi

# Activate venv
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

# Upgrade tooling (safe)
python -m pip install -U pip setuptools wheel >/dev/null

# Install minimal deps (avoid Rust builds)
python -m pip install --no-cache-dir \
  "fastapi==0.99.1" \
  "starlette==0.27.0" \
  "uvicorn==0.25.0" \
  "pydantic==1.10.15" >/dev/null

# Ensure python can see repo root
export PYTHONPATH="$PWD"

echo "✅ Import test…"
python -c "import backend.main as m; assert hasattr(m,'app'), 'backend.main has no app'; print('OK: backend.main:app')"

echo "🚀 Launching…"
exec python -m uvicorn backend.main:app --host "$HOST" --port "$PORT"
