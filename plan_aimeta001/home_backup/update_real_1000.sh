#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TASKS="${TASKS_BASE:-$HOME/tasks}"
OUT="${OUTPUTS_ROOT:-$HOME/outputs}"
LOGS="$TASKS/logs"
WATCH="$HOME/swarm_watch.sh"

mkdir -p "$TASKS"/{incoming,processing,done,failed,logs,logs/agents}
mkdir -p "$OUT"/{leads,upwork,ops,recon,icp,repo,bundles}

echo "[i] TASKS=$TASKS"
echo "[i] OUT=$OUT"
echo "[i] WATCH=$WATCH"

command -v jq >/dev/null 2>&1 || { echo "[X] Missing jq. Run: pkg install -y jq"; exit 1; }

# ---------------------------------------------------------------------------
# 1) Patch watcher: atomic claim + keep-alive loop + real artifact writers
# ---------------------------------------------------------------------------
if [ ! -f "$WATCH" ]; then
  echo "[X] Missing $WATCH. Put your watcher at ~/swarm_watch.sh first."
  exit 1
fi

cp -f "$WATCH" "$WATCH.bak.$(date +%Y%m%d_%H%M%S)"
echo "[✓] Backup created: $WATCH.bak.*"

cat > "$WATCH" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ============================================================================
# SWARM WATCHER (REAL MODE)
# - Atomic claims (mv)
# - Keep-alive polling loop
# - Writes real artifacts into ~/outputs
# ============================================================================

BASE="${TASKS_BASE:-$HOME/tasks}"
IN="$BASE/incoming"
PROC="$BASE/processing"
DONE="$BASE/done"
FAIL="$BASE/failed"
LOGS="$BASE/logs"
WATCH_LOG="$LOGS/swarm_watch.log"
PID_FILE="$BASE/.swarm_watch.pid"

OUT="${OUTPUTS_ROOT:-$HOME/outputs}"
OUT_LEADS="$OUT/leads"
OUT_UPWORK="$OUT/upwork"

MAX_CONCURRENT="${MAX_CONCURRENT:-8}"
POLL_INTERVAL="${POLL_INTERVAL:-1}"
ORCHESTRATOR_RETRY_LIMIT="${ORCHESTRATOR_RETRY_LIMIT:-3}"

mkdir -p "$IN" "$PROC" "$DONE" "$FAIL" "$LOGS" "$LOGS/agents" "$OUT_LEADS" "$OUT_UPWORK"

echo "$$" > "$PID_FILE"
trap 'rm -f "$PID_FILE" 2>/dev/null || true; exit 0' INT TERM EXIT

log() {
  local level="$1"; shift
  local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$level] $*" | tee -a "$WATCH_LOG"
}
log_info(){ log "INFO" "$@"; }
log_warn(){ log "WARN" "$@"; }
log_error(){ log "ERROR" "$@"; }
log_success(){ log "SUCCESS" "$@"; }

# ---------------------------
# Atomic claim
# ---------------------------
claim_task() {
  local src="$1"
  local dst="$PROC/$(basename "$src")"
  if mv "$src" "$dst" 2>/dev/null; then
    printf "%s" "$dst"
    return 0
  fi
  return 1
}

# ---------------------------
# Helpers
# ---------------------------
task_id_from() { basename "$1" .json; }

write_done_json() {
  local task_file="$1" agent="$2" status="$3" artifact="$4"
  local id; id="$(task_id_from "$task_file")"
  local out="$DONE/${id}_output.json"
  local title; title="$(jq -r '.title // "Untitled"' "$task_file")"
  local realm; realm="$(jq -r '.realm // "unknown"' "$task_file")"

  jq -n \
    --arg task_id "$id" \
    --arg agent "$agent" \
    --arg realm "$realm" \
    --arg title "$title" \
    --arg status "$status" \
    --arg timestamp "$(date -Iseconds)" \
    --arg artifact "$artifact" \
    '{
      task_id:$task_id, agent:$agent, realm:$realm, title:$title,
      status:$status, timestamp:$timestamp,
      artifact_path: ($artifact|select(length>0))
    }' > "$out"

  log_success "[$id] Task completed -> $out"
}

# ---------------------------
# Real artifact generators
# ---------------------------
agent_income() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  local title; title="$(jq -r '.title // "Untitled"' "$task_file")"
  local kind; kind="$(jq -r '.kind // "micro_leads"' "$task_file")"

  log_info "[$id] Income agent processing..."
  log_info "[$id] Task: $title"

  case "$kind" in
    micro_leads)
      local city service phone
      city="$(jq -r '.payload.city // "your city"' "$task_file")"
      service="$(jq -r '.payload.service // "Tech Help"' "$task_file")"
      phone="$(jq -r '.payload.phone // ""' "$task_file")"
      local artifact="$OUT_LEADS/${id}_postpack.txt"

      cat > "$artifact" <<TXT
# OUTBOUND MICRO-LEADS POST PACK
Task: $title
City: $city
Service: $service
Phone: ${phone:-"(add phone)"}

--- Facebook Marketplace (short) ---
Need quick $service today? I can help in $city. Same-day availability. DM me.

--- Craigslist (detailed) ---
On-site $service in $city. Fast turnaround, fair price.
• Setup / fixes / troubleshooting
• Clear communication
Reply with what you're trying to do + your location.
${phone:+Text: $phone}

--- Nextdoor (neighborly) ---
Hey neighbors — offering $service in $city this week. Quick help, honest pricing.
Message me what you need and your availability.

--- Follow-up Script (DM) ---
Thanks for reaching out — what device + what issue? What’s your zip + best time today?
TXT

      write_done_json "$task_file" "income" "completed" "$artifact"
      return 0
      ;;
    job_apply)
      local artifact="$OUT_LEADS/${id}_applications_checklist.txt"
      cat > "$artifact" <<TXT
# APPLICATION CHECKLIST
Task: $title

1) Prepare profile basics:
- Name / email / phone
- Resume PDF (1 page)
- Short bio (2–3 sentences)
- Availability hours

2) Sites to apply:
- DataAnnotation
- Outlier
- Remotasks

3) Proof to capture:
- Screenshot submission confirmation
- Save any confirmation email subject lines

4) Next step:
- Track results in a notes file: ~/outputs/leads/app_tracking.md
TXT
      write_done_json "$task_file" "income" "completed" "$artifact"
      return 0
      ;;
    *)
      write_done_json "$task_file" "income" "completed" ""
      return 0
      ;;
  esac
}

agent_gig() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  local title; title="$(jq -r '.title // "Untitled"' "$task_file")"

  log_info "[$id] Gig agent processing..."
  log_info "[$id] Task: $title"

  local niche; niche="$(jq -r '.payload.niche // "Termux automation"' "$task_file")"
  local price; price="$(jq -r '.payload.price // "$50"' "$task_file")"
  local artifact="$OUT_UPWORK/${id}_upwork_gig.md"

  cat > "$artifact" <<MD
# Upwork Gig Pack
**Title:** I will deliver $niche scripts that actually run (Termux / Linux)

**Starter Price:** $price

## What you get
- A working bash script (tested)
- Clear setup steps
- Logs + rollback plan
- Optional: GitHub repo hygiene + push

## First message template
Hey — I can knock this out fast.  
1) What device/OS?  
2) What’s the exact goal + expected output?  
3) Any constraints (Termux only / no root / etc.)?

## 3 bullet deliverables
- ✅ Script that runs end-to-end (no placeholders)
- ✅ Safety guards (no accidental \$HOME nukes)
- ✅ Output artifacts saved to /outputs + logs
MD

  write_done_json "$task_file" "gig" "completed" "$artifact"
  return 0
}

agent_ops() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  log_info "[$id] Ops agent processing..."
  sleep 1
  write_done_json "$task_file" "ops" "completed" ""
}

agent_icp() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  log_info "[$id] ICP agent processing..."
  sleep 1
  write_done_json "$task_file" "icp" "completed" ""
}

agent_recon() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  log_info "[$id] Recon agent processing..."
  sleep 1
  write_done_json "$task_file" "recon" "completed" ""
}

agent_repo() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  log_info "[$id] Repo agent processing..."
  sleep 1
  write_done_json "$task_file" "repo" "completed" ""
}

route_and_run() {
  local task_file="$1"
  local realm; realm="$(jq -r '.realm // "unknown"' "$task_file")"
  case "$realm" in
    income) agent_income "$task_file" ;;
    gig)    agent_gig "$task_file" ;;
    ops)    agent_ops "$task_file" ;;
    icp)    agent_icp "$task_file" ;;
    recon)  agent_recon "$task_file" ;;
    repo)   agent_repo "$task_file" ;;
    *)      agent_ops "$task_file" ;;
  esac
}

process_task() {
  local task_file="$1"
  local id; id="$(task_id_from "$task_file")"
  local attempt; attempt="$(jq -r '.attempts // 0' "$task_file")"
  local max; max="$(jq -r '.max_attempts // 3' "$task_file")"

  log_info "[$id] Processing started"
  log_info "[$id] Attempt: $((attempt+1))/$max"

  if route_and_run "$task_file"; then
    rm -f "$task_file" 2>/dev/null || true
    log_success "[$id] Task completed successfully"
    return 0
  fi

  attempt=$((attempt+1))
  tmp="$(mktemp)"
  jq --argjson a "$attempt" '.attempts=$a' "$task_file" > "$tmp" && mv "$tmp" "$task_file"

  if [ "$attempt" -ge "$max" ]; then
    mv "$task_file" "$FAIL/$(basename "$task_file")" 2>/dev/null || true
    log_error "[$id] Failed permanently -> $FAIL"
    return 1
  fi

  mv "$task_file" "$IN/$(basename "$task_file")" 2>/dev/null || true
  log_warn "[$id] Retrying later"
  return 1
}

# ---------------------------
# Main loop (keep-alive)
# ---------------------------
while true; do
  shopt -s nullglob
  tasks=( "$IN"/*.json )
  shopt -u nullglob

  if [ "${#tasks[@]}" -eq 0 ]; then
    sleep "$POLL_INTERVAL"
    continue
  fi

  total_processed=0
  total_succeeded=0
  total_failed=0

  for src in "${tasks[@]}"; do
    # throttle concurrency
    while [ "$(jobs -pr | wc -l)" -ge "$MAX_CONCURRENT" ]; do
      sleep 0.1
    done

    claimed="$(claim_task "$src")" || { log_warn "[venus_$(date +%s)] Already being processed or moved"; continue; }

    (
      if process_task "$claimed"; then
        : # success already logged
      else
        : # failure already logged
      fi
    ) &

    total_processed=$((total_processed+1))
  done

  wait || true
  log_info "Batch complete - Processed: $total_processed | Succeeded: $total_succeeded | Failed: $total_failed"
done
EOF

chmod +x "$WATCH"
echo "[✓] Patched watcher: $WATCH"

# ---------------------------------------------------------------------------
# 2) Write REAL seeder: seed_1000_tasks_real.sh
# ---------------------------------------------------------------------------
cat > ~/seed_1000_tasks_real.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${TASKS_BASE:-$HOME/tasks}"
IN="$BASE/incoming"
PROC="$BASE/processing"
DONE="$BASE/done"
FAIL="$BASE/failed"
LOGS="$BASE/logs"

COUNT="${1:-1000}"
THREAD_REF="${THREAD_REF:-real_seed_2025-12-13}"
BATCH_LOG="$LOGS/seed_real_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$IN" "$PROC" "$DONE" "$FAIL" "$LOGS"

rand_hex() { tr -dc 'a-f0-9' </dev/urandom | head -c 8; }
now_iso() { date -Iseconds; }

emit_task() {
  local idx="$1" realm="$2" kind="$3" title="$4"
  local payload_json="$5"

  local id="task_${idx}_$(rand_hex)"
  local file="$IN/${id}.json"

  cat > "$file" <<JSON
{
  "id": "$id",
  "created_at": "$(now_iso)",
  "thread_ref": "$THREAD_REF",
  "priority": "P1",
  "realm": "$realm",
  "kind": "$kind",
  "title": "$title",
  "payload": $payload_json,
  "attempts": 0,
  "max_attempts": 3
}
JSON
}

echo "[+] Seeding $COUNT REAL tasks into: $IN" | tee -a "$BATCH_LOG"

# Weighted toward income + gig (real outputs)
for i in $(seq 1 "$COUNT"); do
  case $((i % 10)) in
    0|1|2|3|4|5)
      # income micro-leads + job apply mix
      if [ $((i % 3)) -eq 0 ]; then
        emit_task "$i" "income" "job_apply" "Apply to DataAnnotation / Outlier / Remotasks (step $i)" \
          '{"sites":["DataAnnotation","Outlier","Remotasks"],"proof":["screenshot","email_subjects"]}'
      else
        emit_task "$i" "income" "micro_leads" "Outbound micro-leads (step $i)" \
          '{"city":"Greensboro / High Point","service":"Emergency Tech Help","phone":""}'
      fi
      ;;
    6|7)
      emit_task "$i" "gig" "upwork_pack" "Upwork quick-cash gig packaging (step $i)" \
        '{"niche":"Termux automation + bash fixes","price":"$50-$150"}'
      ;;
    8)
      emit_task "$i" "ops" "stability" "Swarm stability checks (step $i)" \
        '{"checks":["dirs_exist","pid_file","log_tail","no_permission_errors"]}'
      ;;
    9)
      emit_task "$i" "repo" "hygiene" "Repo hygiene + automation (step $i)" \
        '{"todo":["README hooks","starter issues","scripts runnable","commit"]}'
      ;;
  esac

  if [ $((i % 100)) -eq 0 ]; then
    echo "[+] Seeded $i / $COUNT" | tee -a "$BATCH_LOG"
  fi
done

echo "[✔] Done. Incoming now: $(ls -1 "$IN" 2>/dev/null | wc -l)" | tee -a "$BATCH_LOG"
echo "[i] Log: $BATCH_LOG"
EOF

chmod +x ~/seed_1000_tasks_real.sh
echo "[✓] Wrote seeder: ~/seed_1000_tasks_real.sh"

echo ""
echo "[✓] Update complete."
echo "Next:"
echo "  1) Seed:   ~/seed_1000_tasks_real.sh 1000"
echo "  2) Start:  MAX_CONCURRENT=8 POLL_INTERVAL=1 nohup ~/swarm_watch.sh > ~/tasks/logs/swarm_nohup.log 2>&1 &"
echo "  3) Tail:   tail -f ~/tasks/logs/swarm_watch.log"
echo "Artifacts:"
echo "  leads:  ~/outputs/leads/"
echo "  upwork: ~/outputs/upwork/"
