#!/bin/bash
set -euo pipefail

# ---- Usage guard -------------------------------------------------
if [ $# -lt 1 ]; then
  echo "Usage: $0 path/to/audio.mp3 [\"Episode Title (optional)\"]"
  exit 1
fi

SRC="$1"
CUSTOM_TITLE="${2:-}"

if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC"
  exit 1
fi

# ---- Ensure episodes directory exists ----------------------------
mkdir -p episodes

# ---- Compute next episode number ---------------------------------
EXISTING_COUNT=$(ls episodes/*.mp3 2>/dev/null | wc -l || echo 0)
EP_NUMBER=$(( EXISTING_COUNT + 1 ))
FILE="ep$(printf "%03d" "$EP_NUMBER").mp3"

echo "➕ New episode: #$EP_NUMBER → $FILE"

# ---- Copy file into episodes/ ------------------------------------
cp "$SRC" "episodes/$FILE"

# ---- Build rss.xml (header) --------------------------------------
cat > rss.xml << 'HEADER'
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Sovereign Signal</title>
    <link>https://github.com/FacePrintPay/Kre8tiveKonceptz_RepoDepo</link>
    <description>Unfiltered truth from the guy who married his metadata to Bitcoin</description>
    <language>en-us</language>
    <itunes:author>MrGGTP</itunes:author>
    <itunes:explicit>yes</itunes:explicit>
HEADER

# ---- Append latest 20 episodes as <item> tags --------------------
i=0
while IFS= read -r f; do
  i=$((i + 1))
  base=$(basename "$f")

  # Title: use custom title for newest episode if provided,
  # otherwise fallback to file basename without .mp3
  if [ "$i" -eq 1 ] && [ -n "$CUSTOM_TITLE" ]; then
    title="$CUSTOM_TITLE"
  else
    title="${base%.mp3}"
  fi

  # PubDate from file mtime (fallback to now if that fails)
  pubdate=$(date -R -r "$f" 2>/dev/null || date -R)

  cat >> rss.xml <<ITEM
    <item>
      <title>$title</title>
      <enclosure url="https://raw.githubusercontent.com/FacePrintPay/Kre8tiveKonzeptz_RepoDepo/main/episodes/$base" length="99999999" type="audio/mpeg"/>
      <pubDate>$pubdate</pubDate>
    </item>
ITEM

done < <(ls -t episodes/*.mp3 2>/dev/null | head -n 20)

# ---- Close RSS document ------------------------------------------
cat >> rss.xml << 'FOOTER'
  </channel>
</rss>
FOOTER

# ---- Git commit & push -------------------------------------------
git add "episodes/$FILE" rss.xml
git commit -m "Episode $EP_NUMBER dropped"
git push

echo "✅ Episode $EP_NUMBER live everywhere: YouTube, Spotify, Apple, RSS (via GitHub raw)"
