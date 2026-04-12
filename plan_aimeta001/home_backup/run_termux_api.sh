#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "🛠️  Termux FastAPI runner (no reload, no Android watcher pain)"
echo "📍 PWD: $(pwd)"

# --- Config ---
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"

# --- Find the first file that creates a FastAPI app ---
MATCH="$(grep -RIn --include='*.py' 'FastAPI(' . 2>/dev/null | head -n 1 || true)"
if [ -z "$MATCH" ]; then
  echo "❌ Can't find 'FastAPI(' in any .py file from here."
  echo "   Run this from your project root, or make sure your FastAPI app exists."
  exit 1
fi

FILE="$(echo "$MATCH" | cut -d: -f1)"
REL="${FILE#./}"
MOD="${REL%.py}"
MOD="${MOD//\//.}"

# default attribute name
ATTR="app"

# If the file likely uses `application = FastAPI()` or similar, try to detect common names
if ! python - <<PY >/dev/null 2>&1
import importlib
m=importlib.import_module("$MOD")
has = hasattr(m, "$ATTR")
raise SystemExit(0 if has else 1)
PY
then
  for candidate in app api application fastapi_app; do
    if python - <<PY >/dev/null 2>&1
import importlib
m=importlib.import_module("$MOD")
raise SystemExit(0 if hasattr(m, "$candidate") else 1)
PY
    then
      ATTR="$candidate"
      break
    fi
  done
fi

TARGET="${MOD}:${ATTR}"

echo "✅ Detected FastAPI entrypoint:"
echo "   → $TARGET"
echo "🚀 Starting: uvicorn $TARGET --host $HOST --port $PORT (NO --reload)"

# IMPORTANT: no --reload on Termux/shared storage (watchfiles permission errors)
exec uvicorn "$TARGET" --host "$HOST" --port "$PORT" --workers 1
