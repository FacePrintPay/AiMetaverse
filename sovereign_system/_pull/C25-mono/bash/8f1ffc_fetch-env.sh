#!/data/data/com.termux/files/usr/bin/bash
# Fetch environment variables from Obsidian vault via HTTP flow
# Called automatically by MCP server and agents at runtime
OBS_VAULT="${OBSIDIAN_VAULT:-$HOME/C25-Vault}"
ENV_FILE="$OBS_VAULT/05-Configs/.env.active"

fetch_env() {
  local key="$1"
  
  # Try local vault first
  if [ -f "$ENV_FILE" ]; then
    grep "^$key=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- | tr -d '\r' && return 0
  fi
  
  # HTTP flow to Obsidian sync endpoint (port 27124)
  if command -v curl &>/dev/null; then
    curl -s -H "Authorization: Bearer ${OBSIDIAN_API_KEY:-}" \
      "http://localhost:27124/api/vault/note?path=05-Configs/.env.active" 2>/dev/null | \
      jq -r ".content | split(\"\\n\")[] | select(startswith(\"$key=\")) | split(\"=\")[1]" 2>/dev/null && return 0
  fi
  
  # Fallback: check GitHub secrets via gh CLI
  if command -v gh &>/dev/null; then
    gh secret get "$key" 2>/dev/null && return 0
  fi
  
  return 1
}

# Export all required env vars
for key in GITHUB_TOKEN OPENAI_API_KEY VERCEL_TOKEN GOOGLE_CLOUD_KEY OBSIDIAN_API_KEY SERPER_API_KEY; do
  val=$(fetch_env "$key")
  [ -n "$val" ] && export "$key=$val"
done
