#!/bin/bash
# Dependency checker for Mercury
echo "Checking deps for Mercury (intake)..."
MISSING=()
for DEP in bash python3 curl; do
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
