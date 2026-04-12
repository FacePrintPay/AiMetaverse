#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
#  [TOTAL RECALL]  Bard ↔ Gemini Ingestion Correlation Audit
# ==========================================================

ENGINE_ROOT=~/TotalRecall
BARD_LOGS="$ENGINE_ROOT/bard_logs"
TERMUX_LOGS="$ENGINE_ROOT/termux_logs"
OUTPUT_DIR="$ENGINE_ROOT/ingestion_chain"
mkdir -p "$OUTPUT_DIR"

echo "[🔍] Scanning ingestion artifacts..."
find "$BARD_LOGS" "$TERMUX_LOGS" -type f \
  \( -name "bard_*.html" -o -name "*build_push.log" -o -name "*session.log" \) \
  -print > "$OUTPUT_DIR/filelist.txt"

echo "[🔐] Computing SHA-256 hashes..."
> "$OUTPUT_DIR/hash_manifest.txt"
while read -r file; do
  [[ -f "$file" ]] || continue
  sha256sum "$file" >> "$OUTPUT_DIR/hash_manifest.txt"
done < "$OUTPUT_DIR/filelist.txt"

echo "[🧮] Extracting timestamps..."
grep -Eho "20[23][0-9]-[0-9]{2}-[0-9]{2}T[0-9:]{2,8}Z" $(cat "$OUTPUT_DIR/filelist.txt") \
  | sort | uniq > "$OUTPUT_DIR/timestamps.txt"

echo "[📊] Building timeline correlation..."
awk '{print $0,"UTC"}' "$OUTPUT_DIR/timestamps.txt" > "$OUTPUT_DIR/ingestion_timeline.log"

grep -Hn "gcloud\|bard.google.com\|Gemini" $(cat "$OUTPUT_DIR/filelist.txt") \
  > "$OUTPUT_DIR/correlation_hits.log"

echo "[✅] Forensic correlation bundle complete."
echo "Saved to: $OUTPUT_DIR/"
ls -1 "$OUTPUT_DIR"
# [Cross-reference with local Bard logs]
grep -Eho "20[0-9]{2}[-/][0-9]{2}[-/][0-9]{2}[ T][0-9:]{2,8}" "$ENGINE_ROOT/private_logs/bard.txt" \
  | sort | uniq > "$OUTPUT_DIR/private_bard_timestamps.txt"

comm -12 "$OUTPUT_DIR/timestamps.txt" "$OUTPUT_DIR/private_bard_timestamps.txt" \
  > "$OUTPUT_DIR/matched_timestamps.txt"
