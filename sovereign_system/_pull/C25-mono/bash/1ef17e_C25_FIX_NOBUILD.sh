#!/data/data/com.termux/files/usr/bin/bash
# Mars — inject build scripts into all nobuild projects

find /data/data/com.termux/files/home /sdcard \
  -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/playground/*" \
  -not -path "*/template-*" \
  -not -path "*/.git/*" \
  2>/dev/null | while read pkg; do
  DIR=$(dirname "$pkg")
  NAME=$(basename "$DIR")

  # Skip if already has build script
  grep -q '"build"' "$pkg" 2>/dev/null && continue

  echo "━━━ Injecting build: $NAME"

  # Detect what's in the project
  HAS_REACT=$(grep -l "react" "$pkg" 2>/dev/null)
  HAS_SERVER=$(find "$DIR" -maxdepth 2 -name "server.js" -o -name "server.ts" -o -name "index.js" 2>/dev/null | head -1)
  HAS_HTML=$(find "$DIR" -maxdepth 2 -name "index.html" -not -path "*/node_modules/*" 2>/dev/null | head -1)

  # Install vite if react project
  if [ -n "$HAS_REACT" ]; then
    cd "$DIR"
    npm install --save-dev vite @vitejs/plugin-react 2>/dev/null | tail -1
    # Write vite config if missing
    [ ! -f "vite.config.js" ] && cat > vite.config.js << 'VEOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()] })
VEOF
    # Inject build script into package.json
    python3 - << PYEOF
import json
with open('$pkg') as f: p = json.load(f)
p.setdefault('scripts', {})['build'] = 'vite build'
p['scripts']['dev'] = 'vite'
p['scripts']['preview'] = 'vite preview'
with open('$pkg','w') as f: json.dump(p, f, indent=2)
print('  [Mars] Injected vite build → $NAME')
PYEOF
    cd ~

  elif [ -n "$HAS_SERVER" ]; then
    # Node/Express — just copy dist
    python3 - << PYEOF
import json
with open('$pkg') as f: p = json.load(f)
p.setdefault('scripts', {})['build'] = 'echo "server ready"'
p['scripts']['start'] = 'node ${HAS_SERVER#$DIR/}'
with open('$pkg','w') as f: json.dump(p, f, indent=2)
print('  [Mars] Injected server build → $NAME')
PYEOF

  elif [ -n "$HAS_HTML" ]; then
    # Static — no build needed
    python3 - << PYEOF
import json
with open('$pkg') as f: p = json.load(f)
p.setdefault('scripts', {})['build'] = 'echo "static ready"'
with open('$pkg','w') as f: json.dump(p, f, indent=2)
print('  [Mars] Injected static build → $NAME')
PYEOF
  fi

done

echo ""
echo "✅ All nobuild projects fixed"
echo "Now run: bash ~/c25_builds/RUN_ALL_BUILDS.sh"
