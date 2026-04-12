#!/usr/bin/env bash
# C25 TOTAL RECALL - LLM & PLATFORM FORENSIC ANALYSIS
# Cygel White / FacePrintPay / #MrGGTP
# Analyzes patterns across \~3 years of dev evidence

set -u  # error on unset vars

DATE=$(date +%Y%m%d_%H%M%S 2>/dev/null || echo "DATE_FAIL")
ANALYSIS="/sdcard/LLM_FORENSIC_ANALYSIS_${DATE}.txt"

# Fail early if can't write to /sdcard
if ! touch "$ANALYSIS" 2>/dev/null; then
  echo "ERROR: Cannot create $ANALYSIS — run 'termux-setup-storage' and allow permission, then retry."
  exit 1
fi

echo "╔══════════════════════════════════════════════════════╗" | tee "$ANALYSIS"
echo "║   C25 LLM & PLATFORM FORENSIC ANALYSIS ENGINE       ║" | tee -a "$ANALYSIS"
echo "║   Cygel White / FacePrintPay / #MrGGTP              ║" | tee -a "$ANALYSIS"
echo "║   Date: $(date '+%Y-%m-%d %H:%M:%S %Z')             ║" | tee -a "$ANALYSIS"
echo "║   CCPA: #215473345478779                            ║" | tee -a "$ANALYSIS"
echo "║   Court: Greensboro District Court                  ║" | tee -a "$ANALYSIS"
echo "╚══════════════════════════════════════════════════════╝" | tee -a "$ANALYSIS"

echo "" | tee -a "$ANALYSIS"
echo "════════════════════════════════════════════" | tee -a "$ANALYSIS"
echo "FINDING 1: LLM PLATFORM API DEPENDENCIES" | tee -a "$ANALYSIS"
echo "════════════════════════════════════════════" | tee -a "$ANALYSIS"

echo "Scanning for LLM platform references in home dir..." | tee -a "$ANALYSIS"

for PLATFORM in anthropic claude openai gemini grok groq mistral cohere huggingface ollama llama bard vertex bedrock; do
  COUNT=$(grep -rliI --exclude-dir={node_modules,.git,.venv,__pycache__} "$PLATFORM" \~ 2>/dev/null | wc -l)
  echo "  $PLATFORM: $COUNT files" | tee -a "$ANALYSIS"
done

echo "" | tee -a "$ANALYSIS"
echo "Potential shared API key / endpoint patterns (top 15):" | tee -a "$ANALYSIS"
grep -rliI --exclude-dir={node_modules,.git} -E 'api_key|API_KEY|apiKey|ANTHROPIC|OPENAI|sk-' \~ 2>/dev/null | head -15 | tee -a "$ANALYSIS"

echo "" | tee -a "$ANALYSIS"
echo "AI-related strings in JSON files (top hits):" | tee -a "$ANALYSIS"
find \~ /sdcard -type f -name "*.json" 2>/dev/null | grep -v node_modules | xargs grep -il "anthropic\|openai\|claude\|gemini" 2>/dev/null | head -10 | tee -a "$ANALYSIS"

# ... (rest of your sections with similar hardening)

echo "" | tee -a "$ANALYSIS"
echo "════════════════════════════════════════════" | tee -a "$ANALYSIS"
echo "FINDING 2: DEPLOYMENT ATTEMPTS VS SUCCESS RATIO" | tee -a "$ANALYSIS"
echo "════════════════════════════════════════════" | tee -a "$ANALYSIS"

HIST_FILE="/sdcard/TERMUX_COMPLETE_HISTORY.txt"
if [[ -f "$HIST_FILE" ]]; then
  PUSH_COUNT=$(grep -c "git push" "$HIST_FILE" 2>/dev/null || echo 0)
  VERCEL_COUNT=$(grep -cE "vercel (deploy|--prod)" "$HIST_FILE" 2>/dev/null || echo 0)
  DOCKER_COUNT=$(grep -cE "docker (push|build)" "$HIST_FILE" 2>/dev/null || echo 0)
  NPM_COUNT=$(grep -cE "npm (run build|start|deploy)" "$HIST_FILE" 2>/dev/null || echo 0)
  NODE_COUNT=$(grep -cE "node (server|index|app)" "$HIST_FILE" 2>/dev/null || echo 0)
else
  echo "(History file $HIST_FILE not found — counts = 0)" | tee -a "$ANALYSIS"
  PUSH_COUNT=0 VERCEL_COUNT=0 DOCKER_COUNT=0 NPM_COUNT=0 NODE_COUNT=0
fi

echo "  Git push attempts:         $PUSH_COUNT" | tee -a "$ANALYSIS"
echo "  Vercel deploy attempts:    $VERCEL_COUNT" | tee -a "$ANALYSIS"
echo "  Docker push/build:         $DOCKER_COUNT" | tee -a "$ANALYSIS"
echo "  NPM build/deploy:          $NPM_COUNT" | tee -a "$ANALYSIS"
echo "  Node server starts:        $NODE_COUNT" | tee -a "$ANALYSIS"
TOTAL_ATTEMPTS=$((PUSH_COUNT + VERCEL_COUNT + DOCKER_COUNT + NPM_COUNT + NODE_COUNT))
echo "  TOTAL DEPLOYMENT ATTEMPTS: $TOTAL_ATTEMPTS" | tee -a "$ANALYSIS"
echo "  TOTAL DEPLOYMENT ATTEMPTS: $TOTAL_ATTEMPTS" | tee -a "$ANALYSIS"

echo "" | tee -a "$ANALYSIS"
echo "Success markers in files:" | tee -a "$ANALYSIS"
SUCCESS=$(grep -rliI --exclude-dir={node_modules,.git} -E 'COMPLETE|deployed|DEPLOYED|LIVE|ONLINE' \~ 2>/dev/null | wc -l)
echo "  Files with success markers: $SUCCESS" | tee -a "$ANALYSIS"

# Add the remaining sections similarly (failure patterns, timeline, conclusions, etc.)
# For brevity here, insert your original FINDING 3–6 blocks with the same style of fallbacks
# Example for SYNTAX_FAILED:
BASE="/sdcard/TOTALRECALL_20260321_080135"
SYNTAX_FILE="$BASE/SYNTAX_FAILED.txt"
if [[ -f "$SYNTAX_FILE" ]]; then
  echo "" | tee -a "$ANALYSIS"
  echo "Failed scripts from $SYNTAX_FILE:" | tee -a "$ANALYSIS"
  cat "$SYNTAX_FILE" | tee -a "$ANALYSIS"
else
  echo "(No $SYNTAX_FILE found)" | tee -a "$ANALYSIS"
fi

# ... continue with git loops, platform counts, wipe indicators, conclusions cat << 'FINDINGS' ...

echo "" | tee -a "$ANALYSIS"
echo "Report SHA256 for chain of custody:" | tee -a "$ANALYSIS"
sha256sum "$ANALYSIS" 2>/dev/null | tee -a "$ANALYSIS"

echo "" | tee -a "$ANALYSIS"
echo "Analysis complete → see $ANALYSIS" | tee -a "$ANALYSIS"
