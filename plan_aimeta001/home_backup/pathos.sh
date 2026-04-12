#!/data/data/com.termux/files/usr/bin/bash
# PaTHos / SovereignGTP CLI entrypoint

set -e

ROOT="$HOME/PATHOS_OS"

cd "$ROOT" || {
  echo "[!] PATHOS_OS not found at $ROOT"
  exit 1
}

if [ $# -lt 1 ]; then
  echo "Usage: pathos.sh <function> [args...]"
  echo "Example:"
  echo "  pathos.sh mercury_nlp_analysis \"Hello from SovereignGTP\""
  exit 1
fi

python - "$@" << 'PYEOF'
import sys
from pathos.run import run

if len(sys.argv) < 2:
    print("Usage: pathos.sh <function> [args...]")
    raise SystemExit(1)

fn = sys.argv[1]
args = sys.argv[2:]

try:
    result = run(fn, *args)
    print(result)
except Exception as e:
    print(f"[PaTHos error] {e}")
    raise SystemExit(1)
PYEOF
