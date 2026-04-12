#!/bin/bash
# Dependency checker for Eris
echo "Checking deps for Eris (optimize)..."
MISSING=()
for DEP in python3 nodejs; do
    if command -v "$DEP" &>/dev/null; then
        echo "  ✓ $DEP"
    else
        echo "  ✗ $DEP MISSING"
        MISSING+=("$DEP")
    fi
done
if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "Install missing: pkg install ${MISSING[*]}"
    exit 1
fi
echo "All deps OK"
