#!/data/data/com.termux/files/usr/bin/bash
# C25 SCRAPER AGENT — BeautifulSoup web scraper
# Input: URL + prompt
# Output: structured JSON → notebook LLM
C25_HOME="$HOME/constellation25"
SCRAPER_PY="$C25_HOME/scraper.py"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

URL="${1:-}"
PROMPT="${2:-clone this website}"
OLLAMA="${3:-http://localhost:11434}"

[ -z "$URL" ] && { echo "Usage: scraper_agent.sh <url> [prompt] [ollama_url]"; exit 1; }

echo "[$(ts)] [SCRAPER_AGENT] Scraping: $URL"

if [ -f "$SCRAPER_PY" ]; then
  python3 "$SCRAPER_PY" "$URL" "$PROMPT" "$OLLAMA"
else
  echo "[$(ts)] [SCRAPER_AGENT] ERROR: scraper.py not at $SCRAPER_PY"
fi
