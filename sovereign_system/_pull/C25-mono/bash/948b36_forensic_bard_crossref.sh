#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================
# [TOTAL RECALL]  Bard ↔ Wayback Ingestion Cross-Reference Tool
# Auto-versioned forensic run with SHA-256 integrity hash
# ==============================================================

ENGINE_ROOT=~/TotalRecall
LOGS_DIR="$ENGINE_ROOT/private_logs"
INGEST_DIR="$ENGINE_ROOT/ingestion_chain"
PDF_PATH=~/storage/downloads/Bard.pdf

# Create timestamped subfolder
RUNSTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RUN_DIR="$INGEST_DIR/runs/$RUNSTAMP"
mkdir -p "$RUN_DIR" "$LOGS_DIR"

echo "[📦] Converting Bard PDF to text..."
pkg install -y poppler > /dev/null 2>&1
pdftotext "$PDF_PATH" "$LOGS_DIR/bard_extracted.txt"

echo "[🔍] Extracting timestamps..."
grep -Eho "20[0-9]{2}[-/][0-9]{2}[-/][0-9]{2}|[A-Z][a-z]{2} ?[0-9]{1,2},? ?20[0-9]{2}" \
  "$LOGS_DIR/bard_extracted.txt" | sort | uniq > "$LOGS_DIR/bard_timestamps.txt"

echo "[🔑] Extracting keyword hits..."
grep -Ehi "Gemini|PaLM|Vertex|Lambda|AiMetaverse|BitBucks|PaTHos|Metaverse" \
  "$LOGS_DIR/bard_extracted.txt" > "$RUN_DIR/keyword_hits.txt"

echo "[🧩] Cross-referencing with Wayback ingestion data..."
comm -12 "$INGEST_DIR/timestamps_raw.txt" "$LOGS_DIR/bard_timestamps.txt" \
  > "$RUN_DIR/matched_timestamps.txt"

echo "[🧾] Building correlation summary..."
{
  echo "============================="
  echo "[BARD ↔ WAYBACK CORRELATION]"
  echo "Generated on: $(date)"
  echo "Run Folder: $RUN_DIR"
  echo "============================="
  echo ""
  echo "Top Ingestion Days:"
  head -20 "$INGEST_DIR/timestamp_bursts.txt"
  echo ""
  echo "Matched Timestamps:"
  cat "$RUN_DIR/matched_timestamps.txt"
  echo ""
  echo "Keyword Hits:"
  cat "$RUN_DIR/keyword_hits.txt" | head -50
} > "$RUN_DIR/correlation_summary.txt"

echo "[🔐] Generating SHA-256 integrity hash..."
sha256sum "$RUN_DIR/correlation_summary.txt" > "$RUN_DIR/hash_manifest.txt"

echo "[✅] Cross-reference complete."
echo "Summary: $RUN_DIR/correlation_summary.txt"
echo "Hash log: $RUN_DIR/hash_manifest.txt"

# auto-display summary
echo ""
echo "================ CORRELATION SUMMARY ================"
cat "$RUN_DIR/correlation_summary.txt" | less
