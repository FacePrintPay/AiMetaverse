#!/data/data/com.termux/files/usr/bin/bash
set -e

TARGET_LINES=100
BATCH_DIR="batches"

echo "🌍 Normalizing batch files in: $BATCH_DIR"
echo "Target lines per file: $TARGET_LINES"
echo ""

for file in "$BATCH_DIR"/*.txt; do
  [ -f "$file" ] || continue

  current=$(wc -l < "$file")
  base=$(basename "$file")
  echo "→ $base has $current lines"

  if [ "$current" -ge "$TARGET_LINES" ]; then
    echo "   ✓ already >= $TARGET_LINES, skipping"
    echo ""
    continue
  fi

  category="${base%.txt}"
  n=$((current + 1))

  while [ "$n" -le "$TARGET_LINES" ]; do
    printf "Auto-generated task %03d for %s\n" "$n" "$category" >> "$file"
    n=$((n + 1))
  done

  new_count=$(wc -l < "$file")
  echo "   ➕ padded to $new_count lines"
  echo ""
done

echo "✅ All batch files normalized."
