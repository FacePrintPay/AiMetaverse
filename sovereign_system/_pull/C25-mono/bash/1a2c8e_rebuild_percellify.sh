#!/data/data/com.termux/files/usr/bin/bash

# === PATHS ===
LOG="$HOME/AiKre8tiveGenesis/platform/logs/deploy.log"
PERCELLIFIED="$HOME/AiKre8tiveGenesis/platform/logs/percellified.html"

# === FETCH LATEST DEPLOY LOG ===
echo "🔄 Pulling Vercel logs..."
LATEST_DEPLOY=$(vercel ls --limit 1 | awk 'NR==2 {print $1}')
vercel logs "$LATEST_DEPLOY" > "$LOG"

# === BUILD PERCELLIFIED HTML ===
mkdir -p "$(dirname "$PERCELLIFIED")"

{
  echo "<!DOCTYPE html><html><head><meta charset='utf-8'><title>Percellified</title></head><body><div class='box'>"
  while IFS= read -r line; do
    if [[ "$line" == *"Success"* ]]; then
      echo "<div class='line success'>$line</div>"
    elif [[ "$line" == *"Error"* ]]; then
      echo "<div class='line error'>$line</div>"
    else
      echo "<div class='line info'>$line</div>"
    fi
  done < "$LOG"
  echo "</div></body></html>"
} > "$PERCELLIFIED"

echo "✅ Percellified Log Updated at: $PERCELLIFIED"
