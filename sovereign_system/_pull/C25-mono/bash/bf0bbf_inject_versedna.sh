#!/bin/bash
set -euo pipefail
echo "🧬 Injecting VerseDNA module into system..."
cp -r ./modules/versedna ./core/
echo "✅ VerseDNA module injected into core stack."
