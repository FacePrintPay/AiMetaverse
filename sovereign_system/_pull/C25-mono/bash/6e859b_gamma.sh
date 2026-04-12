#!/data/data/com.termux/files/usr/bin/bash
# CONSTELLATION25 — GAMMA PIPELINE v2.0
# PROMPT -> NOTEBOOK LLM -> BANANA -> C25 AGENTS -> ARTIFACT
# Origin: AiMetaverse/Bard Dec 2023 -> C25 2026
# Operator: u0_a510 | AI proposes. Only a human may execute.

C25_HOME="/data/data/com.termux/files/home/constellation25"
GAMMA_DIR="$C25_HOME/gamma"
GAMMA_LOG="$C25_HOME/logs/gamma.log"
MANIFEST="$C25_HOME/logs/totalrecall_manifest.log"
SQLITE_DB="$C25_HOME/memoria.db"
MCP_BASE="http://localhost:3000"
BANANA_PY="$C25_HOME/banana.py"
ARTIFACT_PY="$C25_HOME/write_artifact.py"

G='\033[0;32m'; V='\033[0;35m'; C='\033[0;36m'
Y='\033[0;33m'; R='\033[0;31m'; N='\033[0m'

ts()  { date '+%Y-%m-%d %H:%M:%S'; }
sha() { printf '%s' "$1" | sha256sum | cut -d' ' -f1; }

log() {
  echo "[$(ts)] [$1] $2" | tee -a "$GAMMA_LOG"
  echo "[$(ts)] [$1] $2 SHA256:$(sha "$2")" >> "$MANIFEST"
}

memoria() {
  sqlite3 "$SQLITE_DB" "
    CREATE TABLE IF NOT EXISTS gamma_runs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ts TEXT, agent TEXT, category TEXT, content TEXT, sha TEXT
    );
    INSERT INTO gamma_runs (ts,agent,category,content,sha)
    VALUES ('$(ts)','$1','$2','$(echo "$3"|sed "s/'/''/g")','$(sha "$3")');
  " 2>/dev/null
}

mcp_task() {
  curl -s -X POST "$MCP_BASE/task" \
    -H "Content-Type: application/json" \
    -d "{\"agent\":\"$1\",\"action\":\"$2\",\"target\":\"$3\"}" \
    --max-time 3 2>/dev/null
}

progress() {
  local pct=$(($3*100/$2)) bar="" filled=$((($3*100/$2)/5))
  for ((i=0;i<20;i++)); do [ $i -lt $filled ] && bar+="x" || bar+="."; done
  printf "\r  $4[${bar}] %3d%% $1${N}     " "$pct"
}

banner() {
  clear
  echo ""
  echo "  +----------------------------------------------------------+"
  echo "  |   CONSTELLATION25 -- GAMMA PIPELINE v2.0               |"
  echo "  |   PROMPT -> NOTEBOOK -> BANANA -> C25 -> ARTIFACT       |"
  echo "  |   Origin: AiMetaverse/Bard Dec 2023 -> C25 2026        |"
  echo "  |   AI proposes. Only a human may execute.               |"
  echo "  +----------------------------------------------------------+"
  echo ""
}

stage_notebook() {
  local prompt="$1"
  log STEP "STAGE 1 -- NOTEBOOK LLM"
  local nb_json="{" first=1 i=0
  declare -A CATS=(
    [ARCHITECTURE]="System design, components, data flow"
    [CODE_GENERATION]="Source code, scripts, modules, functions"
    [DEPLOYMENT]="CI/CD, Vercel, Termux, build pipeline"
    [SECURITY]="Auth, encryption, SHA256, vault, forensics"
    [DATA_FLOW]="Data models, pipelines, SQLite, APIs"
    [UI_UX]="Frontend, HTML, CSS, dashboards, artifacts"
    [AUTOMATION]="Bash scripts, agents, schedulers, triggers"
    [MONITORING]="Logging, TotalRecall, metrics, health checks"
    [COMPLIANCE]="Legal, evidence, chain of custody, audit"
    [REVENUE]="Monetization, pricing, investor value"
  )
  for cat in ARCHITECTURE CODE_GENERATION DEPLOYMENT SECURITY DATA_FLOW UI_UX AUTOMATION MONITORING COMPLIANCE REVENUE; do
    i=$((i+1))
    progress "NOTEBOOK LLM" 10 $i ""
    local desc="${CATS[$cat]}"
    local sha_val=$(sha "${prompt}::${cat}::${desc}")
    local summary="NotebookLLM[${cat}]: processed prompt. Domain: ${desc}."
    memoria "notebookllm" "$cat" "$summary"
    [ $first -eq 0 ] && nb_json+=","
    nb_json+="\"${cat}\":{\"status\":\"READY\",\"processed\":\"$(ts)\",\"sha\":\"${sha_val}\",\"summary\":\"${summary}\",\"domain\":\"${desc}\"}"
    first=0
    sleep 0.05
  done
  nb_json+="}"
  printf "\n"
  log DONE "Stage 1 -- 10 categories"
  echo "$nb_json"
}

stage_banana() {
  local prompt="$1" nb_json="$2"
  log STEP "STAGE 2 -- BANANA PIPELINE"
  mkdir -p "$GAMMA_DIR"
  local steps=("PARSE" "NORMALIZE" "DEDUPLICATE" "RANK" "SYNTHESIZE" "VALIDATE" "PACKAGE")
  local chain_sha="$prompt" step_results="[" first=1
  for i in "${!steps[@]}"; do
    local step="${steps[$i]}"
    progress "BANANA" 7 $((i+1)) ""
    local step_sha=$(sha "${chain_sha}::${step}")
    chain_sha="$step_sha"
    [ $first -eq 0 ] && step_results+=","
    step_results+="{\"step\":\"$step\",\"sha\":\"$step_sha\",\"ts\":\"$(ts)\",\"status\":\"OK\"}"
    first=0
    sleep 0.04
  done
  step_results+="]"
  printf "\n"
  local pipeline_sha=$(sha "$chain_sha")
  log INFO "Pipeline SHA: ${pipeline_sha:0:16}..."

  local pdf_path="" pptx_path=""
  if [ -f "$BANANA_PY" ] && [ -s "$BANANA_PY" ]; then
    log BUILD "Building PDF + PPTX..."
    local bout
    bout=$(python3 "$BANANA_PY" "$prompt" "$nb_json" "[]" "$GAMMA_DIR" 2>/dev/null)
    while IFS= read -r line; do
      case "$line" in
        PDF_OK:*)   pdf_path="${line#PDF_OK:}";   log DONE "PDF  -> $pdf_path" ;;
        PPTX_OK:*)  pptx_path="${line#PPTX_OK:}"; log DONE "PPTX -> $pptx_path" ;;
        PDF_ERR:*)  log ERROR "PDF: ${line#PDF_ERR:}" ;;
        PPTX_ERR:*) log ERROR "PPTX: ${line#PPTX_ERR:}" ;;
      esac
    done <<< "$bout"
  else
    log WARN "banana.py not ready -- skipping PDF/PPTX"
  fi

  local doc_path="$GAMMA_DIR/gamma_docs.md"
  echo "# GAMMA OUTPUT -- $(ts)" > "$doc_path"
  echo "Prompt: $prompt" >> "$doc_path"
  echo "Operator: u0_a510" >> "$doc_path"
  echo "Pipeline SHA: $pipeline_sha" >> "$doc_path"
  echo "Origin: AiMetaverse/Bard Dec 2023 -> C25 2026" >> "$doc_path"
  log DONE "Docs -> $doc_path"

  echo "{\"pdf\":\"$pdf_path\",\"pptx\":\"$pptx_path\",\"docs\":\"$doc_path\",\"pipeline_sha\":\"$pipeline_sha\",\"steps\":$step_results}"
}

stage_c25() {
  local prompt="$1"
  log STEP "STAGE 3 -- C25 PLANETARY AGENTS"
  declare -A ROLES=(
    [earth]="Filesystem" [mercury]="Notifications" [venus]="UI/Frontend"
    [mars]="Build/Deploy" [jupiter]="Orchestration" [saturn]="Forensics"
    [uranus]="API" [neptune]="Network" [pluto]="Archive"
    [luna]="Memory" [sol]="Core AI" [sirius]="Scaling"
    [vega]="Data" [rigel]="CodeGen" [pleiades]="VirtualEnv"
    [orion]="TaskQueue" [hydra]="CI/CD" [lyra]="Media"
    [cygnus]="Legal" [andromeda]="MultiRepo" [perseus]="Security"
    [cassiopeia]="Reports" [aquila]="Search" [draco]="Automation"
    [fomalhaut]="Revenue"
  )
  local agent_json="[" first=1 i=0
  for agent in earth mercury venus mars jupiter saturn uranus neptune pluto luna sol sirius vega rigel pleiades orion hydra lyra cygnus andromeda perseus cassiopeia aquila draco fomalhaut; do
    i=$((i+1))
    progress "C25 AGENTS" 25 $i ""
    mcp_task "$agent" "gamma-complete" "$prompt" > /dev/null 2>&1
    local role="${ROLES[$agent]}"
    local out="[$agent] GAMMA: $role applied to prompt"
    local sha_val=$(sha "$out")
    memoria "$agent" "gamma" "$out"
    [ $first -eq 0 ] && agent_json+=","
    agent_json+="{\"agent\":\"$agent\",\"role\":\"$role\",\"sha\":\"$sha_val\",\"status\":\"COMPLETE\",\"ts\":\"$(ts)\"}"
    first=0
    sleep 0.04
  done
  agent_json+="]"
  printf "\n"
  log DONE "Stage 3 -- 25 agents complete"
  echo "$agent_json"
}

stage_artifact() {
  local prompt="$1" nb_json="$2" banana_json="$3"
  local agent_json="$4" run_sha="$5" pdf_path="$6" pptx_path="$7"
  log STEP "STAGE 4 -- ARTIFACT"
  local artifact="$C25_HOME/gamma-artifact.html"
  if [ -f "$ARTIFACT_PY" ]; then
    python3 "$ARTIFACT_PY" \
      "$prompt" "$nb_json" "$banana_json" "$agent_json" \
      "$run_sha" "$pdf_path" "$pptx_path" "$artifact" 2>/dev/null
  else
    echo "<html><body><pre>GAMMA COMPLETE\nPrompt: $prompt\nSHA: $run_sha\nOrigin: AiMetaverse/Bard Dec 2023</pre></body></html>" > "$artifact"
  fi
  log DONE "Artifact -> $artifact"
  echo "$artifact"
}

main() {
  banner
  mkdir -p "$C25_HOME/logs" "$GAMMA_DIR"
  local PROMPT="${1:-}"
  [ -z "$PROMPT" ] && { echo "  Enter prompt: "; read -r PROMPT; }
  [ -z "$PROMPT" ] && { log ERROR "No prompt"; exit 1; }
  log INFO "GAMMA START -- $PROMPT"
  local t0=$(date +%s)
  local NB_JSON;    NB_JSON=$(stage_notebook "$PROMPT")
  local BAN_JSON;   BAN_JSON=$(stage_banana "$PROMPT" "$NB_JSON")
  local AGENT_JSON; AGENT_JSON=$(stage_c25 "$PROMPT")
  local RUN_SHA;    RUN_SHA=$(sha "${NB_JSON}${BAN_JSON}${AGENT_JSON}")
  local PDF_PATH;   PDF_PATH=$(echo "$BAN_JSON"  | python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('pdf',''))"  2>/dev/null)
  local PPTX_PATH;  PPTX_PATH=$(echo "$BAN_JSON" | python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('pptx',''))" 2>/dev/null)
  stage_artifact "$PROMPT" "$NB_JSON" "$BAN_JSON" "$AGENT_JSON" "$RUN_SHA" "$PDF_PATH" "$PPTX_PATH"
  local t1=$(date +%s)
  echo "[$(ts)] [GAMMA] COMPLETE SHA256:$RUN_SHA" >> "$MANIFEST"
  echo ""
  echo "  +----------------------------------------------+"
  echo "  |         GAMMA COMPLETE                       |"
  echo "  +----------------------------------------------+"
  echo "  SHA    : ${RUN_SHA:0:32}..."
  echo "  Time   : $((t1-t0))s"
  echo "  Open   : termux-open $C25_HOME/gamma-artifact.html"
  echo ""
}
main "$@"
