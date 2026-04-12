#!/bin/bash
# Dependency checker for Ceres
echo "Checking deps for Ceres (index)..."
MISSING=()
for DEP in find grep fd; do
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
