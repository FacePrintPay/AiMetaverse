#!/data/data/com.termux/files/usr/bin/bash
BASE="$HOME/TotalRecall/complaint_project"
OUT="$BASE/final_output"
HTML="$OUT/WHITE_v_GOOGLE_FULL_COMPLAINT_$(date +%Y%m%d_%H%M%S).html"

mkdir -p "$OUT"

echo "════════════════════════════════════════════════════════════════"
echo "🧱 Building Full HTML Complaint File..."
echo "════════════════════════════════════════════════════════════════"

cat > "$HTML" <<HTML_HEAD
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>WHITE v. GOOGLE LLC – Complete Complaint</title>
<style>
body { font-family:'Courier New',monospace;background:#0a0a0a;color:#e0e0e0;padding:40px; }
h1,h2 { color:#00ff9f;border-bottom:1px solid #00ff9f;padding-bottom:5px; }
pre { background:#111;padding:15px;border-radius:8px;overflow-x:auto; }
details { background:#1a1a1a;margin:10px 0;padding:10px;border-radius:8px; }
summary { cursor:pointer;font-weight:bold;color:#00ff9f; }
.timestamp { color:#888;font-size:0.9em; }
</style>
</head>
<body>
<h1>WHITE v. GOOGLE LLC — COMPLETE COMPLAINT</h1>
<p class="timestamp">Generated: $(date -Iseconds)</p>
<p>This file combines all verified components from the TotalRecall complaint project. Each section below includes authenticated evidence, legal filings, and supporting data.</p>
<hr>
HTML_HEAD

# add all text and JSON files safely
for f in "$BASE"/FINAL_PACKAGE/*.txt "$BASE"/FINAL_PACKAGE/*.json; do
  [ -f "$f" ] || continue
  fname=$(basename "$f")
  {
    echo "<details><summary>$fname</summary><pre>"
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$f"
    echo "</pre></details>"
  } >> "$HTML"
done 2>/dev/null

# evidence blockchain
if [ -f "$BASE/strategic_tools/evidence/evidence_blockchain_manifest.txt" ]; then
  {
    echo "<details open><summary>Evidence Blockchain Manifest</summary><pre>"
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$BASE/strategic_tools/evidence/evidence_blockchain_manifest.txt"
    echo "</pre></details>"
  } >> "$HTML"
fi

# snapshot
SNAP=$(ls -t "$OUT"/complaint_snapshot_*.txt 2>/dev/null | head -n1)
if [ -n "$SNAP" ]; then
  {
    echo "<details><summary>System Snapshot ($(basename "$SNAP"))</summary><pre>"
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$SNAP"
    echo "</pre></details>"
  } >> "$HTML"
fi

cat >> "$HTML" <<HTML_FOOT
<hr>
<p><em>End of Document — LEGYC Protocol Verified</em></p>
</body>
</html>
HTML_FOOT

echo "✅ HTML complaint built:"
echo "   $HTML"
echo "════════════════════════════════════════════════════════════════"
