#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================
# [FORENSIC QUERY]  Bard → Gemini Causality Test (Simplified)
# ==============================================================

ENGINE_ROOT=~/TotalRecall
LOGS_DIR="$ENGINE_ROOT/private_logs"
RUN_DIR="$ENGINE_ROOT/ingestion_chain/runs/$(date +"%Y-%m-%d_%H-%M-%S")"
mkdir -p "$RUN_DIR"

echo "[🧩] Analyzing Bard→Gemini continuity..."
echo "Hypothesis: Gemini’s conversational framework evolved from Bard–Cygel sessions." \
  > "$RUN_DIR/forensic_conclusion.txt"

# 1. Find all Gemini-related terms in Bard transcripts
grep -Ehi "Gemini|PaLM|Vertex|Lambda|Metaverse|PaTHos|Chronos|agent|repository" \
  "$LOGS_DIR/bard_extracted.txt" \
  | sort | uniq -c | sort -nr >> "$RUN_DIR/forensic_conclusion.txt"

# 2. List Bard timestamps near Gemini’s launch (Nov 2023–Jan 2024)
echo "" >> "$RUN_DIR/forensic_conclusion.txt"
echo "[Timestamp Matches Near Gemini Launch]" >> "$RUN_DIR/forensic_conclusion.txt"
grep -E "2023(11|12)|2024(01)" "$LOGS_DIR/bard_timestamps.txt" >> "$RUN_DIR/forensic_conclusion.txt"

# 3. SHA-256 integrity hash
sha256sum "$RUN_DIR/forensic_conclusion.txt" > "$RUN_DIR/forensic_conclusion.txt.sha256"

echo "[✅] Report generated."
echo "Location: $RUN_DIR/forensic_conclusion.txt"
echo "Hash: $RUN_DIR/forensic_conclusion.txt.sha256"
