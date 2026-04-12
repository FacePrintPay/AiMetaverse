#!/data/data/com.termux/files/usr/bin/bash
# ════════════════════════════════════════════════════
# CONSTELLATION25 — AGENT CONTEXT LOADER
# Source this in any agent to load full platform awareness
# ════════════════════════════════════════════════════
TRAINING="$HOME/github-repos/Constillation25/_unified_build/training_dataset"
export CONSTELLATION_INTENT=$(cat "$TRAINING/00_three_year_intent.md" 2>/dev/null)
export CONSTELLATION_INTEL=$(cat "$TRAINING/01_platform_intelligence.md" 2>/dev/null)
export CONSTELLATION_AGENTS=$(cat "$TRAINING/02_agent_directives.md" 2>/dev/null)
export CONSTELLATION_API=$(cat "$TRAINING/04_unified_api.md" 2>/dev/null)
export CONSTELLATION_CONTEXT="$CONSTELLATION_INTENT

---

$CONSTELLATION_INTEL"
echo "✓ Constellation25 context loaded"
echo "  Intent  : $(echo $CONSTELLATION_INTENT | wc -w) words"
echo "  Intel   : $(echo $CONSTELLATION_INTEL  | wc -w) words"
echo "  Agents  : $(echo $CONSTELLATION_AGENTS | wc -w) words"
