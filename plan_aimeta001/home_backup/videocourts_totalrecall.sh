#!/data/data/com.termux/files/usr/bin/bash
set -e

PORT=31623
ROOT="${1:-$HOME}"
OUT="$HOME/totalrecall_output"

mkdir -p "$OUT"

echo "🧠 VideoCourts TotalRecall — Sovereign File Indexer"
echo "📂 Scanning: $ROOT"
echo "📦 Output: $OUT"
echo ""

INDEX_JSON="$OUT/index.json"
INDEX_HTML="$OUT/index.html"

echo "[" > "$INDEX_JSON"

FIRST=1

find "$ROOT" -type f 2>/dev/null | while read -r file; do
  # skip junk
  case "$file" in
    */.git/*|*/node_modules/*|*/venv/*) continue ;;
  esac

  SIZE=$(stat -c %s "$file" 2>/dev/null || echo 0)
  MTIME=$(stat -c %y "$file" 2>/dev/null || echo "")
  HASH=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')

  [ -z "$HASH" ] && continue

  [ $FIRST -eq 0 ] && echo "," >> "$INDEX_JSON"
  FIRST=0

  printf '{ "path": "%s", "size": %s, "mtime": "%s", "sha256": "%s" }' \
    "$file" "$SIZE" "$MTIME" "$HASH" >> "$INDEX_JSON"
done

echo "]" >> "$INDEX_JSON"

echo "✓ index.json written"

cat > "$INDEX_HTML" << 'HTML'
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>VideoCourts TotalRecall</title>
<style>
body { font-family: system-ui; background:#0b0b0f; color:#eaeaf0; }
h1 { color:#9ddcff; }
input { width:100%; padding:10px; margin:10px 0; }
table { width:100%; border-collapse: collapse; }
th, td { border-bottom:1px solid #333; padding:6px; font-size:12px; }
tr:hover { background:#1a1a22; }
</style>
</head>
<body>
<h1>⚖️ VideoCourts — TotalRecall Evidence Viewer</h1>
<input id="search" placeholder="Filter paths / hashes…" oninput="filter()" />
<table>
<thead>
<tr><th>Path</th><th>Size</th><th>Modified</th><th>SHA-256</th></tr>
</thead>
<tbody id="rows"></tbody>
</table>

<script>
fetch('index.json').then(r=>r.json()).then(data=>{
  window.DATA=data;
  render(data);
});

function render(data){
  const rows=document.getElementById('rows');
  rows.innerHTML='';
  data.forEach(f=>{
    const tr=document.createElement('tr');
    tr.innerHTML=`<td>${f.path}</td><td>${f.size}</td><td>${f.mtime}</td><td>${f.sha256}</td>`;
    rows.appendChild(tr);
  });
}

function filter(){
  const q=document.getElementById('search').value.toLowerCase();
  render(DATA.filter(f =>
    f.path.toLowerCase().includes(q) ||
    f.sha256.includes(q)
  ));
}
</script>
</body>
</html>
HTML

echo "✓ index.html written"
echo ""
echo "🚀 Serving at http://127.0.0.1:$PORT/index.html"
cd "$OUT"
python -m http.server "$PORT"
