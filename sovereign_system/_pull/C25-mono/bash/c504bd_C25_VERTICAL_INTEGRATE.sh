#!/data/data/com.termux/files/usr/bin/bash
# C25 VERTICAL INTEGRATION
# 1. Clone ALL GitHub repos
# 2. Clone ALL Vercel projects  
# 3. Wire them into one sovereign hub
# 4. Each gets its own URL + shared backbone

LOGDIR="$HOME/agent_logs"
HUB="$HOME/c25-sovereign-hub"
REPOS="$HOME/c25-all-repos"
mkdir -p "$HUB" "$REPOS" "$LOGDIR"

echo "╔══════════════════════════════════════════╗"
echo "║  C25 VERTICAL INTEGRATION ENGINE        ║"
echo "╚══════════════════════════════════════════╝"

# ── STEP 1: Clone ALL GitHub repos ──────────────
echo "[Saturn] Cloning all GitHub repos..."
gh repo list FacePrintPay --limit 200 --json name,url,description \
  --jq '.[] | "\(.name)|\(.url)"' 2>/dev/null | while IFS='|' read name url; do
  dest="$REPOS/$name"
  if [ ! -d "$dest" ]; then
    echo "  ► $name"
    gh repo clone "FacePrintPay/$name" "$dest" -- --depth 1 -q 2>/dev/null && \
      echo "  ✓ $name" || echo "  ✗ $name"
  else
    echo "  ✓ $name (exists)"
  fi
done

REPO_COUNT=$(ls "$REPOS" | wc -l)
echo "[Saturn] $REPO_COUNT repos cloned"

# ── STEP 2: Get ALL Vercel projects ─────────────
echo ""
echo "[Cygnus] Fetching all Vercel projects..."
vercel ls 2>/dev/null | grep -v "^>" | grep -v "^$" | \
  awk '{print $1, $2}' | tee "$LOGDIR/vercel_projects.txt"
VERCEL_COUNT=$(wc -l < "$LOGDIR/vercel_projects.txt")
echo "[Cygnus] $VERCEL_COUNT Vercel projects found"

# ── STEP 3: Build sovereign hub ─────────────────
echo ""
echo "[Jupiter] Building sovereign hub..."
mkdir -p "$HUB/src/apps" "$HUB/src/shared" "$HUB/public"

# Scan all repos and register them
python3 << PYEOF
import os, json

repos_dir = "$REPOS"
hub_dir = "$HUB"
apps = []

for name in os.listdir(repos_dir):
    path = os.path.join(repos_dir, name)
    if not os.path.isdir(path): continue
    
    # Detect type
    pkg = os.path.join(path, "package.json")
    has_pkg = os.path.exists(pkg)
    has_index = os.path.exists(os.path.join(path, "index.html"))
    has_server = os.path.exists(os.path.join(path, "server.js"))
    
    app_type = "static"
    if has_pkg:
        try:
            p = json.load(open(pkg))
            deps = {**p.get("dependencies",{}), **p.get("devDependencies",{})}
            if "next" in deps: app_type = "nextjs"
            elif "vite" in deps: app_type = "vite"
            elif "react" in deps: app_type = "react"
            elif "express" in deps: app_type = "express"
        except: pass
    
    apps.append({
        "name": name,
        "path": path,
        "type": app_type,
        "url": f"https://{name.lower()}.vercel.app"
    })

# Write hub registry
registry = os.path.join(hub_dir, "src/shared/registry.json")
with open(registry, "w") as f:
    json.dump({"apps": apps, "total": len(apps)}, f, indent=2)
print(f"[Jupiter] Registered {len(apps)} apps in hub")

# Write hub index.html — master dashboard
hub_html = os.path.join(hub_dir, "public/index.html")
cards = ""
for app in apps:
    cards += f"""
    <a href="{app['url']}" target="_blank" class="card">
      <div class="type">{app['type']}</div>
      <div class="name">{app['name']}</div>
      <div class="url">{app['url']}</div>
    </a>"""

with open(hub_html, "w") as f:
    f.write(f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>C25 Sovereign Hub — FacePrintPay</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:#0a0a0f;color:#f8fafc;font-family:'DM Sans',sans-serif;padding:2rem}}
h1{{font-size:2rem;background:linear-gradient(135deg,#7c3aed,#06b6d4);-webkit-background-clip:text;-webkit-text-fill-color:transparent;margin-bottom:.5rem}}
.meta{{color:#94a3b8;margin-bottom:2rem;font-size:.875rem}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:1rem}}
.card{{background:#0f0f1a;border:1px solid #1e1e2e;border-radius:12px;padding:1.25rem;text-decoration:none;color:inherit;transition:all .2s;display:block}}
.card:hover{{border-color:#7c3aed;transform:translateY(-2px)}}
.type{{font-size:.65rem;color:#7c3aed;text-transform:uppercase;letter-spacing:.1em;margin-bottom:.5rem}}
.name{{font-size:.95rem;font-weight:600;margin-bottom:.35rem}}
.url{{font-size:.7rem;color:#94a3b8}}
</style>
</head>
<body>
<h1>C25 Sovereign Hub</h1>
<p class="meta">Cygel White / FacePrintPay Inc. — {len(apps)} sovereign builds | Prior Art 2022</p>
<div class="grid">{cards}</div>
</body>
</html>""")
print(f"[Venus] Hub dashboard written: {hub_html}")
PYEOF

# ── STEP 4: Package hub for Vercel ──────────────
cat > "$HUB/vercel.json" << 'VEOF'
{
  "version": 2,
  "rewrites": [{"source": "/(.*)", "destination": "/index.html"}]
}
VEOF

cd "$HUB"
git init 2>/dev/null
git add -A
git commit -m "C25 Sovereign Hub — $(date +%Y-%m-%d)" 2>/dev/null

# Deploy hub
echo ""
echo "[Cygnus] Deploying sovereign hub..."
HUB_URL=$(vercel --yes --prod 2>/dev/null | tail -1)
echo "  🚀 HUB LIVE → $HUB_URL"

# ── STEP 5: Deploy each repo solo ───────────────
echo ""
echo "[Mars] Deploying each repo as solo environment..."
while read dir; do
  name=$(basename "$dir")
  echo "  ► $name"
  cd "$dir"
  [ ! -f vercel.json ] && \
    echo '{"version":2,"rewrites":[{"source":"(.*)","destination":"/index.html"}]}' \
    > vercel.json
  [ -f package.json ] && npm install --silent 2>/dev/null
  [ -f package.json ] && npm run build --silent 2>/dev/null
  vercel --yes --prod -e NODE_ENV=production 2>/dev/null | tail -1 | \
    xargs -I{} echo "    🚀 $name → {}"
  cd ~
done < ~/agent_logs/REAL_PROJECTS.txt

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  VERTICAL INTEGRATION COMPLETE          ║"
echo "╚══════════════════════════════════════════╝"
echo "  Hub: $HUB_URL"
echo "  Repos: $REPO_COUNT"
echo "  Vercel: $VERCEL_COUNT"
echo "  Solo deploys: $(wc -l < ~/agent_logs/REAL_PROJECTS.txt)"
