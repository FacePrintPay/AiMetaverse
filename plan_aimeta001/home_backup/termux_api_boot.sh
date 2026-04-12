#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# --------- Defaults (hard-bound) ----------
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
SEARCH_DIR="${SEARCH_DIR:-$HOME/sovereignGTP-fullstack}"
ATTR_DEFAULT="${ATTR_DEFAULT:-app}"

echo "🛠️  Termux FastAPI boot (no reload, no Rust builds)"
echo "📍 PWD: $(pwd)"
echo "🔎 SEARCH_DIR: $SEARCH_DIR"
echo "🌐 HOST: $HOST  PORT: $PORT"

[ -d "$SEARCH_DIR" ] || { echo "❌ SEARCH_DIR not found: $SEARCH_DIR"; exit 1; }
cd "$SEARCH_DIR"

# --------- venv (isolates deps from system python) ----------
if [ ! -d ".venv_termux_api" ]; then
  echo "🧪 Creating venv: .venv_termux_api"
  python -m venv .venv_termux_api
fi

# shellcheck disable=SC1091
source .venv_termux_api/bin/activate

# --------- Termux-friendly requirements ----------
# NOTE: We avoid pydantic-core entirely (no Rust).
cat > requirements.termux.txt <<'EOF'
uvicorn==0.25.0
httpx==0.25.2
aiofiles==23.2.1
python-multipart==0.0.6
python-dotenv==1.0.0
requests==2.31.0

# FastAPI stack (pydantic v1 path)
pydantic==1.10.15
starlette==0.27.0
fastapi==0.99.1
EOF

echo "📦 Installing deps (venv, no cache)…"
python -m pip install --no-cache-dir -U pip >/dev/null
python -m pip install --no-cache-dir -r requirements.termux.txt >/dev/null

# --------- Imports from project root ----------
export PYTHONPATH="$PWD"

# --------- Find a FastAPI() definition ----------
PYFILES="$(find . -maxdepth 6 -type f -name "*.py" 2>/dev/null | head -n 1200 || true)"
[ -n "$PYFILES" ] || { echo "❌ No *.py found under $SEARCH_DIR"; exit 1; }

CANDIDATE_FILE="$(
  echo "$PYFILES" | while IFS= read -r f; do
    grep -q "FastAPI(" "$f" 2>/dev/null && { echo "$f"; break; }
  done
)"

[ -n "${CANDIDATE_FILE:-}" ] || {
  echo "❌ Couldn't find any file that contains FastAPI("
  echo "   Try setting SEARCH_DIR to the folder with your backend/main.py"
  exit 1
}

MOD="${CANDIDATE_FILE#./}"
MOD="${MOD%.py}"
MOD="${MOD//\//.}"

# --------- Detect attribute (app/api/application/etc.) ----------
ATTR="$ATTR_DEFAULT"

python -c "import importlib,sys;m=importlib.import_module('$MOD');sys.exit(0 if hasattr(m,'$ATTR') else 1)" >/dev/null 2>&1 || {
  for cand in app api application fastapi_app server; do
    if python -c "import importlib,sys;m=importlib.import_module('$MOD');sys.exit(0 if hasattr(m,'$cand') else 1)" >/dev/null 2>&1; then
      ATTR="$cand"
      break
    fi
  done
}

TARGET="${MOD}:${ATTR}"

echo "✅ Entrypoint: $TARGET"
echo "🚀 Starting uvicorn (NO --reload)…"
exec uvicorn "$TARGET" --host "$HOST" --port "$PORT" --workers 1
