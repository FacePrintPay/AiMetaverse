#!/data/data/com.termux/files/usr/bin/bash

INPUT="$HOME/AiKre8tiveGenesis/platform/logs/percellified.html"
OUTPUT="$HOME/AiKre8tiveGenesis/platform/logs/tailwind_view.html"

if [[ ! -f "$INPUT" ]]; then
  echo "❌ Source file not found: $INPUT"
  exit 1
fi

LOG_LINES=$(sed -n 's/.*<div class=.line[^>]*>\(.*\)<\/div>.*/\1/p' "$INPUT")

cat <<HTML > "$OUTPUT"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Percellified Viewer</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-black text-green-400 font-mono p-8">
  <div class="max-w-5xl mx-auto">
    <h1 class="text-3xl font-bold text-center mb-6 text-green-300">AiKre8tive Log Dialog Viewer</h1>
    <div class="bg-gray-900 border border-green-600 rounded-xl p-6 overflow-y-auto max-h-[75vh] whitespace-pre-wrap shadow-xl">
HTML

if [[ -z "$LOG_LINES" ]]; then
  echo "<p class='text-red-400'>⚠️ No dialog lines found in log.</p>" >> "$OUTPUT"
else
  echo "$LOG_LINES" | while read -r line; do
    echo "<div class='my-1'>$line</div>" >> "$OUTPUT"
  done
fi

cat <<HTML >> "$OUTPUT"
    </div>
    <div class="mt-8 text-center text-gray-400 text-xs">Generated: $(date)</div>
  </div>
</body>
</html>
HTML

echo "✅ Tailwind log view created at: $OUTPUT"
termux-open "$OUTPUT"
