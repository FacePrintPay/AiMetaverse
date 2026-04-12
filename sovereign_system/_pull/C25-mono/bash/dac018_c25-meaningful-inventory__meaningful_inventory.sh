# REPO: c25-meaningful-inventory | FILE: meaningful_inventory.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="$HOME/termux_meaningful_inventory_$TS"
mkdir -p "$OUT"
MASTER="$OUT/all_meaningful_files.txt"
> "$MASTER"
SCAN_DIRS=(
  "$HOME"
  "$HOME/repos"
  "$HOME/backup"
)
EXCLUDES=(
  "$HOME/.npm/_cacache"
  "$HOME/.cache"
  "$HOME/node_modules"
)
find_cmd() {
  for d in "${EXCLUDES[@]}"; do
    printf -- "-path %q -prune -o " "$d"
  done
}
for D in "${SCAN_DIRS[@]}"; do
  [ -d "$D" ] || continue
  eval find "$D" \
    $(find_cmd) \
    -type f \( \
      -iname '*.html' -o \
      -iname '*.mht'  -o \
      -iname '*.md'   -o \
      -iname '*.markdown' -o \
      -iname 'readme*' -o \
      -iname '*.py'   -o \
      -iname '*.json' -o \
      -iname '*.pdf'  -o \
      -iname '*.txt'  \
    \) -print >> "$MASTER"
done
awk -F. 'NF>1{ext=tolower($NF); c[ext]++} END{for(e in c) print c[e], e}' \
  "$MASTER" | sort -nr > "$OUT/files_by_type.txt"
echo
echo "Inventory complete:"
echo "  Files list : $MASTER"
echo "  Type counts: $OUT/files_by_type.txt"
echo "  Total meaningful files: $(wc -l < "$MASTER")"
