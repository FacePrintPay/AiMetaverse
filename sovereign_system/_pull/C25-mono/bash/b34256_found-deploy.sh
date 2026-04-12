link_vercel_projects() {   log "═══ LINKING VERCEL PROJECTS ═══"; 
  vercel ls 2>/dev/null | tee "$WORK_DIR/vercel-projects.txt" || true;    info "Vercel projects listed in: $WORK_DIR/vercel-projects.txt";   info "Any unlinked repos will be auto-linked on first deploy"; }
# ── PRIORITY REPOS — DEPLOY FIRST ─────────────────────────────────
deploy_priority() {   log "═══ PRIORITY DEPLOYMENTS ═══";    declare -A PRIORITY_REPOS=(     ["VideoCourts"]="https://github.com/FacePrintPay/VideoCourts"     ["SovereignGTP"]="https://github.com/FacePrintPay/SovereignGTP"     ["PaThosAi"]="https://github.com/FacePrintPay/PaThosAi"     ["constellation25"]="https://github.com/FacePrintPay/constellation25"     ["MyBuyo"]="https://github.com/FacePrintPay/MyBuyo"     ["TotalRecall"]="https://github.com/FacePrintPay/TotalRecall"   );    for REPO in "${!PRIORITY_REPOS[@]}"; do     audit_repo "$REPO" "${PRIORITY_REPOS[$REPO]}";   done; }
# ── BULK AUDIT ALL REPOS ───────────────────────────────────────────
deploy_all() {   log "═══ BULK AUDIT ALL REPOS ═══";    jq -r '.[] | "\(.name) \(.url)"' "$WORK_DIR/repos.json" |   while read REPO_NAME REPO_URL; do
    case "$REPO_NAME" in       VideoCourts|SovereignGTP|PaThosAi|constellation25|MyBuyo|TotalRecall)         info "Already deployed: $REPO_NAME — skipping";         ((SKIPPED++));         continue;         ;;     esac;     audit_repo "$REPO_NAME" "$REPO_URL" || true;   done; }
# ── FINAL REPORT ───────────────────────────────────────────────────
report() {   log "═══════════════════════════════════════";   log "C25 DEPLOY AUDIT COMPLETE";   log "═══════════════════════════════════════";   echo -e "${G}  ✓ PASSED:  $PASS${NC}";   echo -e "${Y}  ⚡ FIXED:   $FIXED${NC}";   echo -e "${R}  ✗ FAILED:  $FAIL${NC}";   echo -e "${C}  → SKIPPED: $SKIPPED${NC}";   log "Full log: $LOG";   log "Vercel dashboard: https://vercel.com/dashboard";   log "GitHub Pages: https://github.com/orgs/FacePrintPay/repositories";    if [ $FAIL -gt 0 ]; then     log "═══ FAILURES REQUIRING MANUAL ACTION ═══";     grep "✗" "$LOG" | tail -20;   fi; }
# ── MAIN ───────────────────────────────────────────────────────────
main() {   clear;   echo -e "${C}"
--
 ██║      █████╔╝███████╗    ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝
 ██║     ██╔═══╝ ╚════██║    ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝
 ╚██████╗███████╗███████║    ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║
  ╚═════╝╚══════╝╚══════╝    ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝
BANNER
   echo -e "${NC}";   log "STARTING: FacePrintPay Full Deploy Audit";   log "Target: github.com/$GITHUB_USER — ALL REPOS";    preflight;   fetch_repos;   link_vercel_projects;   deploy_priority;   deploy_all;   enable_pages;   report; }
main "$@"
gh auth status
vercel whoami
which jq && which node && which npm
#!/data/data/com.termux/files/usr/bin/bash
--
info() { echo -e "${C}  → $*${NC}"  | tee -a "$LOG"; }
mkdir -p "$WORK/repos"
# ── PREFLIGHT ──────────────────────────────────────────────────────
preflight() {   log "PREFLIGHT";   gh auth status &>/dev/null   && ok "gh authenticated"   || { err "gh not authed — run: gh auth login";   exit 1; };   vercel whoami  &>/dev/null   && ok "vercel: $(vercel whoami)" || { err "vercel not authed — run: vercel login"; exit 1; };   command -v jq  &>/dev/null   && ok "jq ok"              || { pkg install -y jq; };   command -v node &>/dev/null  && ok "node: $(node -v)"   || { pkg install -y nodejs; }; }
# ── DETECT + FIX + DEPLOY ONE REPO ────────────────────────────────
deploy_repo() {   local NAME="$1";   local ORG="${2:-$GITHUB_USER}";   local DIR="$WORK/repos/$NAME";    log "── $NAME ($ORG) ──"; 
  if [ -d "$DIR/.git" ]; then     git -C "$DIR" pull --rebase -q 2>/dev/null || true;   else     git clone --depth=1 "https://github.com/$ORG/$NAME" "$DIR" -q 2>/dev/null || {
      git clone --depth=1 "git@github.com:$ORG/$NAME.git" "$DIR" -q 2>/dev/null || {         err "Cannot clone $NAME — skipping"; return;       };     };   fi;    cd "$DIR";   local CHANGED=false; 
  local FW="static";   if [ -f package.json ]; then     grep -q '"next"'  package.json 2>/dev/null && FW="nextjs";     grep -q '"vite"'  package.json 2>/dev/null && FW="vite";     grep -q '"react"' package.json 2>/dev/null && [ "$FW" = "static" ] && FW="react";     [ "$FW" = "static" ] && FW="node";   fi;   info "type=$FW"; 
  if [ ! -f .gitignore ]; then     printf 'node_modules/\n.env\n.env.local\n.next/\ndist/\nbuild/\n.vercel/\n*.log\n' > .gitignore;     git add .gitignore; CHANGED=true; fix ".gitignore created";   fi; 
  if [ ! -f vercel.json ]; then     case "$FW" in       nextjs) echo '{"framework":"nextjs"}'                                   > vercel.json ;;       vite)   echo '{"framework":"vite","outputDirectory":"dist"}'            > vercel.json ;;       react)  echo '{"framework":"create-react-app","outputDirectory":"build"}' > vercel.json ;;       node)   echo '{"builds":[{"src":"*.js","use":"@vercel/node"}]}'         > vercel.json ;;       static) echo '{"rewrites":[{"source":"/(.*)","destination":"/index.html"}]}' > vercel.json ;;     esac;     git add vercel.json; CHANGED=true; fix "vercel.json created";   fi; 
--
  if [ "$CHANGED" = true ]; then     git commit -m "chore(c25): deploy audit fixes $(date +%Y-%m-%d)" -q 2>/dev/null || true;     git push origin HEAD -q 2>/dev/null && fix "Pushed fixes: $NAME" || err "Push failed: $NAME";   else     info "No fixes needed";   fi; 
  if ! gh api "repos/$ORG/$NAME/pages" &>/dev/null; then     gh api "repos/$ORG/$NAME/pages" --method POST       -f 'source[branch]=main' -f 'source[path]=/' &>/dev/null &&       fix "GitHub Pages enabled: $NAME" ||       info "Pages not applicable: $NAME";   else     ok "Pages already active: $NAME";   fi; 
  info "Deploying to Vercel...";   if vercel --prod --yes --cwd "$DIR" 2>/dev/null; then     ok "Vercel deployed: $NAME";   else
    vercel link --yes --cwd "$DIR" 2>/dev/null || true;     if vercel --prod --yes --cwd "$DIR" 2>/dev/null; then       ok "Vercel deployed (after link): $NAME";     else       err "Vercel failed: $NAME — check: vercel logs --prod";     fi;   fi;    cd "$WORK"; }
# ── BULK: ALL REMAINING REPOS ──────────────────────────────────────
deploy_all_remaining() {   log "FETCHING ALL REPOS — $GITHUB_USER";   gh repo list "$GITHUB_USER" --limit 300 --json name     | jq -r '.[].name' > "$WORK/all-repos.txt";    TOTAL=$(wc -l < "$WORK/all-repos.txt");   info "Total repos: $TOTAL"; 
  SKIP="SovereignGTP PaThosAi VideoCourts TotalRecall";    while read -r REPO; do     echo "$SKIP" | grep -qw "$REPO" && { info "Already deployed: $REPO"; continue; };     deploy_repo "$REPO" "$GITHUB_USER" || true;   done < "$WORK/all-repos.txt"; 
  for ORG in Constillation25 TheKre8tive Kre8tive-Space VideoCourts; do     log "ORG: $ORG";     gh repo list "$ORG" --limit 50 --json name 2>/dev/null       | jq -r '.[].name' | while read -r REPO; do         deploy_repo "$REPO" "$ORG" || true;       done;   done; }
# ── REPORT ─────────────────────────────────────────────────────────
report() {   echo "";   log "══════════════════════════════════════";   log "C25 STACK DEPLOY COMPLETE";   log "══════════════════════════════════════";   echo -e "${G}  ✓  PASSED  : $PASS${NC}";   echo -e "${Y}  ⚡ FIXED   : $FIXED${NC}";   echo -e "${R}  ✗  FAILED  : $FAIL${NC}";   echo "";   log "Full log  → $LOG";   log "Vercel    → https://vercel.com/dashboard";   log "GitHub    → https://github.com/$GITHUB_USER";   echo "";   if [ $FAIL -gt 0 ]; then     log "FAILURES:";     grep "✗" "$LOG" | tail -30;   fi; }
# ── MAIN ───────────────────────────────────────────────────────────
clear
echo -e "${C}╔═══════════════════════════════════════╗"
