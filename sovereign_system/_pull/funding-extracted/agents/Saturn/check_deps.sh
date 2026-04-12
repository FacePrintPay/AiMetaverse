#!/bin/bash
# Dependency checker for Saturn
echo "Checking deps for Saturn (audit)..."
MISSING=()
for DEP in git sha256sum; do
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
