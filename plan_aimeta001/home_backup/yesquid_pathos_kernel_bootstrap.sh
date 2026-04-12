#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid-1Basher: PaTHos / SovereignGTP Kernel Bootstrap
# Wires:
#   - pathos package
#   - planets namespace
#   - run() dispatcher
#   - pathos.sh CLI launcher
# ==========================================================

set -e

ROOT="$HOME/PATHOS_OS"
PKG="$ROOT/pathos"
PLANETS="$PKG/planets"

echo "[*] YesQuid-1Basher :: Bootstrapping PaTHos kernel..."
echo "[*] ROOT:   $ROOT"
echo "[*] PKG:    $PKG"
echo "[*] PLANETS:$PLANETS"

# --- sanity checks -------------------------------------------------
if [ ! -d "$ROOT" ]; then
  echo "[!] PATHOS_OS not found at $ROOT"
  echo "    mkdir -p \$HOME/PATHOS_OS/pathos/planets and re-run."
  exit 1
fi

mkdir -p "$PKG" "$PLANETS"

# --- core __init__.py (only if missing) ---------------------------
if [ ! -f "$PKG/__init__.py" ]; then
  echo "[*] Creating pathos/__init__.py"
  cat > "$PKG/__init__.py" << 'PYEOF'
"""
PaTHos Core Package - SovereignGTP Runtime
Minimal bootstrap so the compiler and runtime can see the core.
"""
PYEOF
else
  echo "[i] pathos/__init__.py already exists – keeping existing version."
fi

# --- planets __init__.py -------------------------------------------
if [ ! -f "$PLANETS/__init__.py" ]; then
  echo "[*] Creating pathos/planets/__init__.py"
  cat > "$PLANETS/__init__.py" << 'PYEOF'
"""
Planetary Agents Namespace
"""
PYEOF
else
  echo "[i] pathos/planets/__init__.py already exists – keeping existing version."
fi

# --- Mercury stub (only if missing) -------------------------------
if [ ! -f "$PLANETS/mercury.py" ]; then
  echo "[*] Creating planets/mercury.py stub"
  cat > "$PLANETS/mercury.py" << 'PYEOF'
"""
Mercury – NLP analysis entrypoint (placeholder)
"""

def mercury_nlp_analysis(text: str) -> dict:
    """Minimal stub until the full system is reattached."""
    return {
        "input": text,
        "length": len(text),
        "tokens_approx": len(text.split()),
        "sentiment_stub": "neutral"
    }
PYEOF
else
  echo "[i] planets/mercury.py already exists – keeping existing version."
fi

# --- run() dispatcher ----------------------------------------------
if [ -f "$PKG/run.py" ]; then
  BAK="$PKG/run.py.bak.$(date +%s)"
  echo "[i] Backing up existing run.py -> $BAK"
  cp "$PKG/run.py" "$BAK"
fi

echo "[*] Writing pathos/run.py dispatcher"
cat > "$PKG/run.py" << 'PYEOF'
from pathos.planets import mercury

DISPATCH = {
    "mercury_nlp_analysis": mercury.mercury_nlp_analysis,
    # TODO: wire up venus/mars/etc as they get restored
}

def run(function: str, *args, **kwargs):
    """
    Central PaTHos dispatcher.

    Args:
        function: Name of the planetary function to call.
        *args/**kwargs: Arguments forwarded to that function.

    Returns:
        Whatever the target function returns.
    """
    if function not in DISPATCH:
        raise ValueError(f"Invalid function name: {function}")
    return DISPATCH[function](*args, **kwargs)
PYEOF

# --- CLI launcher pathos.sh ----------------------------------------
echo "[*] Installing ~/pathos.sh CLI"

cat > "$HOME/pathos.sh" << 'SHYEOF'
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
SHYEOF

chmod +x "$HOME/pathos.sh"

# --- Smoke test ----------------------------------------------------
echo "[*] Running Mercury smoke test via Python..."

cd "$ROOT"

python - << 'PYEOF'
from pathos.run import run
print(">>> run('mercury_nlp_analysis', 'YesQuid smoke test')")
out = run("mercury_nlp_analysis", "YesQuid smoke test")
print(out)
PYEOF

echo "[✓] PaTHos kernel wired."
echo "[✓] Use:  \$HOME/pathos.sh mercury_nlp_analysis \"Hello SovereignGTP\""
