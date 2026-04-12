#!/data/data/com.termux/files/usr/bin/bash

echo "[⚖️] Initializing LEGYC Auto-Complaint Writer..."

PROJECT_DIR="$HOME/TotalRecall/complaint_project"
TEMPLATE="$PROJECT_DIR/templates/legal_template.txt"
SUMMARY="$PROJECT_DIR/summary.md"
OUTPUT_FILE="$PROJECT_DIR/GEMINI_IP_COMPLAINT_FULL.txt"
EVIDENCE_DIR="$PROJECT_DIR"

# Check required
[ ! -f "$SUMMARY" ] && echo "[❌] Missing summary.md" && exit 1
[ ! -f "$TEMPLATE" ] && echo "[❌] Missing legal_template.txt" && exit 1

# Pull contents safely
INTRO=$(cat "$SUMMARY")
EVIDENCE=$(cat "$EVIDENCE_DIR"/Z-*.txt 2>/dev/null | awk '{print}')
STATUTES=$(cat "$EVIDENCE_DIR/statutes.md" 2>/dev/null || echo "Statutes section missing.")
RELIEF="Plaintiff seeks damages of \$100,000,000 and injunctive relief."
AFFIDAVIT="I, Cygel White (MrGGTP), affirm the above as true to the best of my knowledge."

# Create output by replacing placeholders in template
awk -v intro="$INTRO" \
    -v evidence="$EVIDENCE" \
    -v statutes="$STATUTES" \
    -v relief="$RELIEF" \
    -v affidavit="$AFFIDAVIT" \
    '{
      gsub("{intro_section}", intro);
      gsub("{evidence_section}", evidence);
      gsub("{statutes_section}", statutes);
      gsub("{relief_section}", relief);
      gsub("{affidavit}", affidavit);
      print
    }' "$TEMPLATE" > "$OUTPUT_FILE"

echo "[🔐] SHA256 Hash:"
sha256sum "$OUTPUT_FILE"

echo "[🚀] Complaint Ready!"
termux-open "$OUTPUT_FILE"
