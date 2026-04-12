#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ---- Config (edit if you want) ----
BASE="${TASKS_BASE:-$HOME/tasks}"
IN="$BASE/incoming"
PROC="$BASE/processing"
DONE="$BASE/done"
FAIL="$BASE/failed"
LOGS="$BASE/logs"

COUNT="${1:-1000}"             # allow ./seed_1000_tasks.sh 500
BATCH_LOG="$LOGS/seed_$(date +%Y%m%d_%H%M%S).log"
THREAD_REF="${THREAD_REF:-chat_thread_2025-12}"

mkdir -p "$IN" "$PROC" "$DONE" "$FAIL" "$LOGS"

# ---- helpers ----
rand_hex() { cat /dev/urandom 2>/dev/null | tr -dc 'a-f0-9' | head -c 8; }
now_iso() { date -Is; }

emit_task() {
  local idx="$1"
  local realm="$2"
  local title="$3"
  local cmd="$4"
  local tags="$5"

  local id="task_${idx}_$(rand_hex)"
  local file="$IN/${id}.json"

  # Avoid overwriting if rerun (rare collision)
  if [ -f "$file" ]; then
    return 0
  fi

  cat > "$file" <<EOF
{
  "id": "$id",
  "created_at": "$(now_iso)",
  "thread_ref": "$THREAD_REF",
  "priority": "P1",
  "realm": "$realm",
  "title": "$title",
  "desired_outcome": "Produce a concrete output artifact or completed action for: $title",
  "command_hint": "$cmd",
  "tags": [$tags],
  "status": "QUEUED",
  "attempts": 0,
  "max_attempts": 3
}
EOF
}

# ---- task templates (thread-based) ----
# tags must be JSON array items e.g. "income","termux"
TAGS_INCOME='"income","urgent","cashflow","execution"'
TAGS_RECON='"recon","competition","tail","intel"'
TAGS_TERMUX='"termux","bash","android","ops"'
TAGS_PROOT='"proot","ubuntu","dfx","icp","setup"'
TAGS_UPWORK='"upwork","gig","profile","proposal","leadgen"'
TAGS_QA='"ai-eval","qa","taskwork","annotation"'
TAGS_REPO='"git","github","repo","automation"'

# ---- seed loop ----
echo "[+] Seeding $COUNT tasks into: $IN" | tee -a "$BATCH_LOG"

for i in $(seq 1 "$COUNT"); do
  case $((i % 10)) in
    0)
      emit_task "$i" "income" "Apply to DataAnnotation / Outlier / Remotasks (batch step $i)" \
        "Collect required profile fields; submit 3 applications; log confirmation emails/screens." \
        "$TAGS_INCOME,$TAGS_QA"
      ;;
    1)
      emit_task "$i" "gig" "Upwork quick-cash gig packaging (step $i)" \
        "Draft gig title + 3 bullets + rate; publish; screenshot listing." \
        "$TAGS_INCOME,$TAGS_UPWORK"
      ;;
    2)
      emit_task "$i" "ops" "Termux / proot-distro hardening (step $i)" \
        "Verify proot ubuntu installed; verify curl/git; capture versions." \
        "$TAGS_TERMUX,$TAGS_PROOT"
      ;;
    3)
      emit_task "$i" "icp" "DFX setup + smoke test (step $i)" \
        "In proot ubuntu: dfx --version; dfx start --background; dfx ping; log outputs." \
        "$TAGS_PROOT"
      ;;
    4)
      emit_task "$i" "recon" "Competition tail targets maintenance (step $i)" \
        "Validate targets/competition.txt urls; replace noisy sources; keep stable endpoints." \
        "$TAGS_RECON,$TAGS_TERMUX"
      ;;
    5)
      emit_task "$i" "recon" "Competition delta digest (step $i)" \
        "Parse logs/competition_tail.log; summarize deltas; highlight releases/commits." \
        "$TAGS_RECON"
      ;;
    6)
      emit_task "$i" "repo" "Repo hygiene + automation (step $i)" \
        "Add README hooks; add 3 starter issues; ensure scripts runnable; commit." \
        "$TAGS_REPO,$TAGS_TERMUX"
      ;;
    7)
      emit_task "$i" "income" "Local backup safety net (step $i)" \
        "List 3 temp agencies; call script; record names/times; plan morning route." \
        "$TAGS_INCOME"
      ;;
    8)
      emit_task "$i" "ops" "Swarm stability checks (step $i)" \
        "Verify tasks dirs exist; verify watcher running; ensure no permission errors." \
        "$TAGS_TERMUX"
      ;;
    9)
      emit_task "$i" "income" "Outbound micro-leads (step $i)" \
        "Post 1 local ad (FB/CL/Marketplace): 'Emergency Tech Help'; log link/text." \
        "$TAGS_INCOME,$TAGS_UPWORK"
      ;;
  esac

  # progress ping every 50
  if [ $((i % 50)) -eq 0 ]; then
    echo "[+] Seeded $i / $COUNT tasks..." | tee -a "$BATCH_LOG"
  fi
done

echo "[✔] Done. Seeded tasks into: $IN" | tee -a "$BATCH_LOG"
echo "[i] Log: $BATCH_LOG"
echo "[i] Count now: $(ls -1 "$IN" 2>/dev/null | wc -l)"
