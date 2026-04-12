# REPO: c25-meaningful-inventory-fixed | FILE: meaningful_inventory_fixed.sh | CONSTELLATION25

#!/data/data/com.termux/files/usr/bin/bash
TS=$(date +%Y%m%d_%H%M%S)
OUT="$HOME/termux_meaningful_inventory_$TS"
mkdir -p "$OUT"
MASTER="$OUT/all_meaningful_files.txt"
> "$MASTER"
find \
  "$HOME" \
  "/storage/emulated/0" \
  -path "$HOME/.npm/_cacache" -prune -o \
  -path "$HOME/.cache" -prune -o \
  -path "$HOME/node_modules" -prune -o \
  -path "/storage/emulated/0/Android" -prune -o \
  -type f \( \
    -iname "*.html" -o \
    -iname "*.mht" -o \
    -iname "*.md" -o \
    -iname "*.markdown" -o \
    -iname "readme*" -o \
    -iname "*.py" -o \
    -iname "*.json" -o \
    -iname "*.pdf" -o \
    -iname "*.txt" \
  \) -print 2>/dev/null >> "$MASTER"
awk -F. 'NF>1 { ext=tolower($NF); c[ext]++ }
         END { for (e in c) printf "%7d %s\n", c[e], e }' \
  "$MASTER" | sort -nr > "$OUT/files_by_type.txt"
echo
echo "Inventory complete:"
echo "  Files list : $MASTER"
echo "  Type counts: $OUT/files_by_type.txt"
echo "  Total meaningful files: $(wc -l < "$MASTER")"
