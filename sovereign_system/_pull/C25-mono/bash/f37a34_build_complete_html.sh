#!/data/data/com.termux/files/usr/bin/bash
BASE="$HOME/TotalRecall/complaint_project"
OUT="$BASE/final_output"
STAMP=$(date +%Y%m%d_%H%M%S)
HTML="$OUT/WHITE_v_GOOGLE_FULL_COMPLAINT_${STAMP}.html"

mkdir -p "$OUT"

echo "════════════════════════════════════════════════════════════════"
echo "🌐  Building COMPLETE HTML COMPLAINT (all assets)..."
echo "════════════════════════════════════════════════════════════════"

cat > "$HTML" <<HTML_HEAD
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>WHITE v. GOOGLE LLC – Complete Complaint</title>
<style>
body{font-family:'Courier New',monospace;background:#0a0a0a;color:#e0e0e0;padding:40px;}
h1,h2{color:#00ff9f;border-bottom:1px solid #00ff9f;padding-bottom:5px;}
a{color:#00ffff;}
pre{background:#111;padding:15px;border-radius:8px;overflow-x:auto;}
details{background:#1a1a1a;margin:10px 0;padding:10px;border-radius:8px;}
summary{cursor:pointer;font-weight:bold;color:#00ff9f;}
.timestamp{color:#888;font-size:0.9em;}
hr{border:0;border-top:1px solid #00ff9f;margin:25px 0;}
</style>
</head>
<body>
<h1>WHITE v. GOOGLE LLC — COMPLETE COMPLAINT</h1>
<p class="timestamp">Generated: $(date -Iseconds)</p>
<p>This document merges all verified components, exhibits, blockchain manifests, and archived materials from the TotalRecall complaint project.</p>
<hr>
<h2>Table of Contents</h2>
<ul id="toc">
HTML_HEAD

# Build TOC
for f in "$BASE"/FINAL_PACKAGE/* "$BASE"/strategic_tools/evidence/* "$OUT"/*.txt "$OUT"/*.pdf; do
  [ -f "$f" ] || continue
  id=$(basename "$f" | sed 's/[^a-zA-Z0-9]/_/g')
  echo "<li><a href=\"#$id\">$(basename "$f")</a></li>" >> "$HTML"
done

cat >> "$HTML" <<HTML_BODY
</ul>
<hr>
HTML_BODY

# Include text/json inline
for f in "$BASE"/FINAL_PACKAGE/*.txt "$BASE"/FINAL_PACKAGE/*.json; do
  [ -f "$f" ] || continue
  id=$(basename "$f" | sed 's/[^a-zA-Z0-9]/_/g')
  {
    echo "<details id=\"$id\"><summary>$(basename "$f")</summary><pre>"
    sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' "$f"
    echo "</pre></details>"
  } >> "$HTML"
done

# Evidence blockchain
if [ -f "$BASE/strategic_tools/evidence/evidence_blockchain_manifest.txt" ]; then
  {
    echo "<details open><summary>Evidence Blockchain Manifest</summary><pre>"
    sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' "$BASE/strategic_tools/evidence/evidence_blockchain_manifest.txt"
    echo "</pre></details>"
  } >> "$HTML"
fi

# Link PDFs and TAR archives
for f in "$BASE"/*.pdf "$BASE"/strategic_tools/evidence/*.pdf "$OUT"/*.pdf "$OUT"/*.tar.gz; do
  [ -f "$f" ] || continue
  id=$(basename "$f" | sed 's/[^a-zA-Z0-9]/_/g')
  name=$(basename "$f")
  echo "<details id=\"$id\"><summary>$name</summary><p><a href=\"$f\" download>Download $name</a></p></details>" >> "$HTML"
done

# Snapshot section
SNAP=$(ls -t "$OUT"/complaint_snapshot_*.txt 2>/dev/null | head -n1)
if [ -n "$SNAP" ]; then
  id=$(basename "$SNAP" | sed 's/[^a-zA-Z0-9]/_/g')
  {
    echo "<details id=\"$id\" open><summary>System Snapshot ($(basename "$SNAP"))</summary><pre>"
    sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' "$SNAP"
    echo "</pre></details>"
  } >> "$HTML"
fi

cat >> "$HTML" <<HTML_FOOT
<hr>
<p><em>End of Document — LEGYC Protocol Verified</em></p>
</body>
</html>
HTML_FOOT

echo "✅ COMPLETE HTML complaint built:"
echo "   $HTML"
echo "════════════════════════════════════════════════════════════════"
