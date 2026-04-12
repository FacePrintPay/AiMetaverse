#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================
# [TOTAL RECALL] BARD Conversation Forensic Analyzer
# Extracts timeline, IP claims, denials, and build context
# ==============================================================

ENGINE_ROOT=~/TotalRecall
LOGS_DIR="$ENGINE_ROOT/private_logs"
RUN_DIR="$ENGINE_ROOT/ingestion_chain/runs/$(date +"%Y-%m-%d_%H-%M-%S")"
mkdir -p "$RUN_DIR"

INPUT="$LOGS_DIR/bard_extracted.txt"
OUT="$RUN_DIR/bard_forensic_summary.txt"

echo "[🔍] Analyzing BARD conversation..."
echo "===================================================" > "$OUT"
echo "BARD Conversation Forensic Summary" >> "$OUT"
echo "Generated: $(date)" >> "$OUT"
echo "===================================================" >> "$OUT"
echo "" >> "$OUT"

# 1️⃣ Detect all timestamps and estimate conversation timeline
grep -Eo "20[0-9]{2}[-/][0-9]{2}[-/][0-9]{2}" "$INPUT" | sort | uniq -c >> "$OUT"

# 2️⃣ Extract ownership claims (you asking about IP rights)
echo "" >> "$OUT"
echo "[IP Ownership Mentions]" >> "$OUT"
grep -i -A2 -B2 "intellectual property" "$INPUT" >> "$OUT"

# 3️⃣ Extract any references to denial or refusal
echo "" >> "$OUT"
echo "[Access / Refusal Mentions]" >> "$OUT"
grep -i -A2 -B2 "release\|access\|deny\|refuse" "$INPUT" >> "$OUT"

# 4️⃣ Extract mentions of build agents or timeline
echo "" >> "$OUT"
echo "[Build / Timeline References]" >> "$OUT"
grep -i -A2 -B2 "months\|timeline\|build\|agents" "$INPUT" >> "$OUT"

# 5️⃣ Generate SHA-256 integrity hash
sha256sum "$OUT" > "$OUT.sha256"

echo "[✅] Forensic analysis complete."
echo "Summary: $OUT"
echo "Hash: $OUT.sha256"
