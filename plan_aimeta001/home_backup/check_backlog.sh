#!/data/data/com.termux/files/usr/bin/bash

echo "📊 SovereignGTP Backlog Status"
echo "=============================="
echo ""

for category in batches/*.txt; do
  name=$(basename "$category" .txt)
  total=$(wc -l < "$category")
  echo "  $name: $total tasks"
done

echo ""
echo "Task Queue:"
echo "  Incoming: $(ls -1 tasks/incoming 2>/dev/null | wc -l)"
echo "  Processed: $(ls -1 tasks/processed 2>/dev/null | wc -l)"
echo ""
echo "Outputs: $(ls -1 outputs 2>/dev/null | wc -l) files"
echo ""
