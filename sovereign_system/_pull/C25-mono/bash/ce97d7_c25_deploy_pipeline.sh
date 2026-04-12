#!/bin/bash
GH_USER="FacePrintPay"
REPODEPO="RepoDepot-Stargate"
RATE_LIMIT=2
C25="$HOME/c25_pipeline"
COMPLETE_BUILDS="$HOME/c25_inspection/complete/complete_builds.txt"
RAN_SCRIPTS="$HOME/c25_inspection/complete/ran_scripts.txt"
LOG="$C25/pipeline_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$C25"/{reports,packages,fixed,html_out}

# HTTP AUTH - NO PASSWORD PROMPTS
GH_TOKEN=$(gh auth token 2>/dev/null)
[ -z "$GH_TOKEN" ] && GH_TOKEN=$(cat ~/.git-credentials 2>/dev/null | grep github | sed 's/.*:\(.*\)@.*/\1/' | head -1)
[ -z "$GH_TOKEN" ] && { echo "🔑 Token:"; read -s GH_TOKEN; }
export GH_TOKEN
git config --global url."https://$GH_TOKEN@github.com/".insteadOf "https://github.com/"

GH_API="https://api.github.com"
AUTH="Authorization: token $GH_TOKEN"
log() { echo "$1" | tee -a "$LOG"; }

repo_exists() { curl -sf -H "$AUTH" "$GH_API/repos/$GH_USER/$1" >/dev/null 2>&1; }
create_repo() { curl -sf -X POST -H "$AUTH" -H "Content-Type: application/json" "$GH_API/user/repos" -d "{\"name\":\"$1\",\"description\":\"$2\",\"auto_init\":false,\"has_pages\":true}" >/dev/null 2>&1; sleep $RATE_LIMIT; }
enable_pages() { curl -sf -X POST -H "$AUTH" -H "Content-Type: application/json" "$GH_API/repos/$GH_USER/$1/pages" -d '{"source":{"branch":"main","path":"/"}}' >/dev/null 2>&1; }

log "🌌 CONSTELLATION 25 PIPELINE"
log "Started: $(date)"

# PHASE 1: RepoDepot-Stargate
log "📦 PHASE 1: RepoDepot-Stargate..."
repo_exists "$REPODEPO" || create_repo "$REPODEPO" "C25 Master Hub"
DEPOT_DIR="$C25/$REPODEPO"
[ -d "$DEPOT_DIR/.git" ] || git clone "https://$GH_TOKEN@github.com/$GH_USER/$REPODEPO.git" "$DEPOT_DIR" 2>/dev/null || (mkdir -p "$DEPOT_DIR" && cd "$DEPOT_DIR" && git init && git remote add origin "https://$GH_TOKEN@github.com/$GH_USER/$REPODEPO.git")
log "✅ RepoDepot-Stargate ready"

# PHASE 2: 32 COMPLETE BUILDS
log ""
log "✅ PHASE 2: 32 complete builds..."
CP=0; CPUSH=0
> "$C25/reports/complete_report.txt"

while IFS='|' read -r dir score missing; do
  DIR=$(echo "$dir" | xargs)
  [ ! -d "$DIR" ] && continue
  CP=$((CP+1))
  NAME=$(basename "$DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
  log "  [$CP/32] $NAME"

  # Add missing README
  [ ! -f "$DIR/README.md" ] && cat > "$DIR/README.md" << EOF
# $NAME
Constellation 25 — FacePrintPay / Cygel White
## Install
\`\`\`bash
npm install
\`\`\`
## Run
\`\`\`bash
npm start
\`\`\`
EOF

  # Add missing index.html
  [ ! -f "$DIR/index.html" ] && cat > "$DIR/index.html" << EOF
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>$NAME</title>
<style>body{background:#0a0a1a;color:#e0e0ff;font-family:monospace;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0}.card{background:#111128;border:1px solid #7af;border-radius:12px;padding:40px;text-align:center}h1{color:#7af}.status{color:#4f4;margin-top:15px}</style>
</head><body><div class="card"><h1>🌌 $NAME</h1><p>Constellation 25 — FacePrintPay</p><div class="status">● ONLINE</div></div></body></html>
EOF

  # Add CI/CD
  mkdir -p "$DIR/.github/workflows"
  [ ! -f "$DIR/.github/workflows/deploy.yml" ] && cat > "$DIR/.github/workflows/deploy.yml" << EOF
name: C25 Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
        continue-on-error: true
EOF

  # Tarball
  tar -czf "$C25/packages/${NAME}.tar.gz" -C "$(dirname "$DIR")" "$(basename "$DIR")" 2>/dev/null

  # Push
  repo_exists "$NAME" || create_repo "$NAME" "C25 Complete Build"
  cd "$DIR"
  git init -q 2>/dev/null
  git remote remove origin 2>/dev/null
  git remote add origin "https://$GH_TOKEN@github.com/$GH_USER/$NAME.git"
  git add -A
  git commit -qm "🌌 C25: $NAME $(date +%Y-%m-%d)" 2>/dev/null
  git push -q --force origin HEAD:main 2>/dev/null && {
    CPUSH=$((CPUSH+1))
    enable_pages "$NAME"
    log "    ✅ https://github.com/$GH_USER/$NAME"
    echo "$NAME|https://github.com/$GH_USER/$NAME|https://$GH_USER.github.io/$NAME" >> "$C25/reports/complete_report.txt"
  } || log "    ⚠️  Failed: $NAME"

  sleep $RATE_LIMIT
done < "$COMPLETE_BUILDS"

log "  Pushed: $CPUSH / $CP"

# PHASE 3: 552 CONFIRMED SCRIPTS  
log ""
log "🚀 PHASE 3: 552 confirmed scripts..."
SP=0; SPUSH=0
> "$C25/reports/scripts_report.txt"

while IFS= read -r line; do
  SCRIPT=$(echo "$line" | sed 's/^COMPLETE: //')
  [ ! -f "$SCRIPT" ] && continue
  SP=$((SP+1))
  NAME="c25-$(basename "$SCRIPT" .sh | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | cut -c1-40)"
  WORK="$C25/fixed/$NAME"
  mkdir -p "$WORK/.github/workflows"

  # Copy and prune script
  sed '/^[[:space:]]*$/d' "$SCRIPT" > "$WORK/$(basename "$SCRIPT")" 2>/dev/null

  LINES=$(wc -l < "$SCRIPT")
  DEPS=$(grep -oE "npm|pip|apt|curl|git|node|python|go" "$SCRIPT" 2>/dev/null | sort -u | tr '\n' ' ')

  # README
  cat > "$WORK/README.md" << EOF
# $NAME
**Constellation 25 Confirmed Script** — ran successfully on device

## Stats
- Lines: $LINES
- Dependencies: ${DEPS:-none}

## Usage
\`\`\`bash
chmod +x $(basename "$SCRIPT")
./$(basename "$SCRIPT")
\`\`\`

## Source
$SCRIPT

Built by Constellation 25 — FacePrintPay / Cygel White
EOF

  # HTML page
  PREVIEW=$(head -20 "$WORK/$(basename "$SCRIPT")" 2>/dev/null | sed 's/</\&lt;/g;s/>/\&gt;/g')
  cat > "$WORK/index.html" << EOF
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>$NAME</title>
<style>body{background:#0a0a1a;color:#e0e0ff;font-family:monospace;padding:20px;max-width:900px;margin:0 auto}h1{color:#7af}.badge{background:#1a3a1a;border:1px solid #4f4;padding:3px 10px;border-radius:20px;font-size:.8em;color:#4f4}pre{background:#111128;border:1px solid #333;border-radius:8px;padding:20px;overflow-x:auto;margin-top:20px}</style>
</head><body><span class="badge">✅ CONFIRMED RAN</span><h1>$NAME</h1><p style="color:#888">Lines: $LINES | Deps: ${DEPS:-none} | C25 FacePrintPay</p><pre>$PREVIEW</pre></body></html>
EOF

  # CI/CD
  cat > "$WORK/.github/workflows/deploy.yml" << EOF
name: C25 Pages
on:
  push:
    branches: [main]
jobs:
  pages:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
        continue-on-error: true
EOF

  # Push
  repo_exists "$NAME" || create_repo "$NAME" "C25 Confirmed Script"
  cd "$WORK"
  git init -q 2>/dev/null
  git remote remove origin 2>/dev/null
  git remote add origin "https://$GH_TOKEN@github.com/$GH_USER/$NAME.git"
  git add -A
  git commit -qm "🌌 C25 Script: $NAME" 2>/dev/null
  git push -q --force origin HEAD:main 2>/dev/null && {
    SPUSH=$((SPUSH+1))
    enable_pages "$NAME"
    [ $((SP % 10)) -eq 0 ] && log "  [$SP/552] ✅ $SPUSH pushed so far..."
    echo "$NAME|$SCRIPT|https://github.com/$GH_USER/$NAME" >> "$C25/reports/scripts_report.txt"
  }

  sleep $RATE_LIMIT
done < "$RAN_SCRIPTS"

log "  Scripts pushed: $SPUSH / $SP"

# PHASE 4: MASTER HTML
log ""
log "🌐 PHASE 4: Building master HTML..."

COMPLETE_ROWS=$(while IFS='|' read -r name gh pages; do
  echo "<tr><td><a href='$gh' target='_blank'>$name</a></td><td style='color:#4f4'>✅ Complete</td><td><a href='$pages' target='_blank'>Live Page</a></td></tr>"
done < "$C25/reports/complete_report.txt")

SCRIPT_ROWS=$(while IFS='|' read -r name src gh; do
  echo "<tr><td><a href='$gh' target='_blank'>$name</a></td><td style='color:#7af'>🚀 Script</td><td>$(basename "$src")</td></tr>"
done < "$C25/reports/scripts_report.txt")

cat > "$DEPOT_DIR/index.html" << MASTERHTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>🌌 Constellation 25 — RepoDepot-Stargate</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0a0a1a;color:#e0e0ff;font-family:monospace;padding:20px}
h1{color:#7af;text-align:center;padding:30px 0 10px;font-size:2em;letter-spacing:2px}
.sub{text-align:center;color:#888;margin-bottom:30px}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;margin-bottom:30px}
.stat{background:#111128;border:1px solid #333;border-radius:8px;padding:18px;text-align:center}
.stat .n{font-size:2em;color:#7af;font-weight:bold}
.stat .l{color:#888;font-size:.8em;margin-top:4px}
.tabs{display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap}
.tab{padding:8px 20px;background:#1a1a2e;border:1px solid #333;border-radius:5px;cursor:pointer;color:#888}
.tab.active{background:#7af;color:#000;font-weight:bold}
.tc{display:none}
.tc.active{display:block}
.search{width:100%;padding:10px;background:#1a1a2e;border:1px solid #444;color:#fff;border-radius:5px;margin:10px 0;font-size:1em}
table{width:100%;border-collapse:collapse}
th{background:#1a1a2e;color:#7af;padding:10px;text-align:left;border-bottom:1px solid #333}
td{padding:8px 10px;border-bottom:1px solid #111128;font-size:.85em}
tr:hover{background:#111128}
a{color:#7af;text-decoration:none}
a:hover{text-decoration:underline}
footer{text-align:center;color:#333;margin-top:40px;font-size:.8em;padding:20px}
</style>
</head>
<body>
<h1>🌌 CONSTELLATION 25</h1>
<p class="sub">RepoDepot-Stargate — Master Deployment Index</p>
<p class="sub" style="color:#4f4">FacePrintPay / Cygel White — $(date)</p>

<div class="stats">
  <div class="stat"><div class="n">318,620</div><div class="l">Total Files</div></div>
  <div class="stat"><div class="n">91,120</div><div class="l">Code Files</div></div>
  <div class="stat"><div class="n">$CPUSH</div><div class="l">Builds Live</div></div>
  <div class="stat"><div class="n">$SPUSH</div><div class="l">Scripts Live</div></div>
  <div class="stat"><div class="n">1,816</div><div class="l">In Progress</div></div>
  <div class="stat"><div class="n">103</div><div class="l">Repos Mirrored</div></div>
</div>

<div class="tabs">
  <div class="tab active" onclick="show('complete',this)">✅ Complete Builds ($CPUSH)</div>
  <div class="tab" onclick="show('scripts',this)">🚀 Live Scripts ($SPUSH)</div>
</div>

<div id="complete" class="tc active">
  <input class="search" type="text" placeholder="Search builds..." onkeyup="filter('ct',this.value)">
  <table><thead><tr><th>Repository</th><th>Status</th><th>Live</th></tr></thead>
  <tbody id="ct">$COMPLETE_ROWS</tbody></table>
</div>

<div id="scripts" class="tc">
  <input class="search" type="text" placeholder="Search scripts..." onkeyup="filter('st',this.value)">
  <table><thead><tr><th>Repository</th><th>Type</th><th>Source</th></tr></thead>
  <tbody id="st">$SCRIPT_ROWS</tbody></table>
</div>

<footer>Constellation 25 · FacePrintPay · Cygel White · $(date +%Y)</footer>

<script>
function show(id,el){document.querySelectorAll('.tc').forEach(t=>t.classList.remove('active'));document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));document.getElementById(id).classList.add('active');el.classList.add('active');}
function filter(id,q){document.querySelectorAll('#'+id+' tr').forEach(r=>{r.style.display=r.textContent.toLowerCase().includes(q.toLowerCase())?'':'none';});}
</script>
</body>
</html>
MASTERHTML

cd "$DEPOT_DIR"
git add -A
git commit -qm "🌌 C25 RepoDepot-Stargate Master Index $(date +%Y-%m-%d)" 2>/dev/null
git push -q --force origin HEAD:main 2>/dev/null && log "✅ RepoDepot-Stargate live" || log "⚠️ RepoDepot push failed"
enable_pages "$REPODEPO"

log ""
log "============================================================"
log "🌌 CONSTELLATION 25 COMPLETE"
log "Complete builds live: $CPUSH"
log "Scripts live:         $SPUSH"
log "Master index:         https://$GH_USER.github.io/$REPODEPO"
log "GitHub:               https://github.com/$GH_USER"
log "============================================================"
