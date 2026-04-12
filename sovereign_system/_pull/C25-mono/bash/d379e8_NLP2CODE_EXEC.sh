#!/usr/bin/env bash
set -Eeuo pipefail

CONTROL="$HOME/CONTROL"
MANIFEST="$HOME/MY_WORK_RECOVERY/file_list.txt"
OUT_CODE="$CONTROL/manifests/EXECUTION_PLAN.sh"
LOG="$CONTROL/manifests/NLP2CODE.log"

exec > >(tee -a "$LOG") 2>&1

echo "🧠 NLP2CODE EXEC START — $(date)"

if [[ ! -f "$MANIFEST" ]]; then
  echo "❌ file_list.txt not found"
  exit 1
fi

#####################################
# PHASE 1 — NLP SIGNAL EXTRACTION
#####################################
echo "🔍 Extracting intent signals"

grep -Ei \
  '(run|build|deploy|agent|stack|system|orchestr|boot|init|sync|start)' \
  "$MANIFEST" > "$CONTROL/manifests/intent_files.txt" || true

#####################################
# PHASE 2 — CODE GENERATION
#####################################
echo "⚙️ Generating executable plan → $OUT_CODE"

cat > "$OUT_CODE" <<'PLAN'
#!/usr/bin/env bash
set -Eeuo pipefail
echo "🚀 EXECUTION PLAN START — $(date)"
PLAN

while IFS= read -r f; do
  [[ ! -f "$f" ]] && continue

  case "$f" in
    *.sh)
      echo "echo '▶ RUN $f'" >> "$OUT_CODE"
      echo "bash \"$f\" || true" >> "$OUT_CODE"
      ;;
    package.json)
      dir="$(dirname "$f")"
      echo "cd \"$dir\" && npm install && npm run build || true" >> "$OUT_CODE"
      ;;
    pyproject.toml|requirements.txt)
      dir="$(dirname "$f")"
      echo "cd \"$dir\" && pip install -r requirements.txt || true" >> "$OUT_CODE"
      ;;
    docker-compose.yml)
      dir="$(dirname "$f")"
      echo "cd \"$dir\" && docker compose up -d --build || true" >> "$OUT_CODE"
      ;;
  esac
done < "$CONTROL/manifests/intent_files.txt"

echo "echo '✅ EXECUTION PLAN COMPLETE'" >> "$OUT_CODE"

chmod +x "$OUT_CODE"

#####################################
# PHASE 3 — EXECUTION
#####################################
echo "🔥 Executing generated plan"
bash "$OUT_CODE"

echo "✅ NLP2CODE EXEC COMPLETE — $(date)"
