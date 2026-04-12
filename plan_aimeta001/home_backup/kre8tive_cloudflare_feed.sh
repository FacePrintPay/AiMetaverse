#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# GITHUB → CLOUDFLARE PAGES → RSS FEED GENERATOR (NO VERCEL)
# Builds static artifacts and pushes to a Pages-connected repo
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------
# Config (edit if needed)
# ---------------------------
ORG="${ORG:-FacePrintPay}"
DOMAIN="${DOMAIN:-kre8tive.space}"

# Local workspace output
FEED_DIR="${FEED_DIR:-$HOME/kre8tive-feed}"

# Where your repos live (used only for context; not required)
REPO_ROOT="${REPO_ROOT:-$HOME/storage/shared/AiMetaverse/plan_aimeta001/repos}"

# IMPORTANT:
# This is the repo Cloudflare Pages is connected to (the "site repo").
# Use RepoDepot-Stargate OR make a new repo like "kre8tive-pages".
PAGES_REPO_PATH="${PAGES_REPO_PATH:-$REPO_ROOT/RepoDepot-Stargate}"

# Where to write the static site inside that repo
# Cloudflare Pages can serve from root or /public.
SITE_DIR_REL="${SITE_DIR_REL:-.}"   # "." = repo root
# SITE_DIR_REL="public"            # if you prefer /public

mkdir -p "$FEED_DIR"

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║                                                ║
║   GITHUB → CLOUDFLARE PAGES → RSS FEED        ║
║   Static build + git push (zero CLI deploy)    ║
║                                                ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${RESET}\n"

# ---------------------------
# Requirements
# ---------------------------
for bin in gh jq sed; do
  command -v "$bin" >/dev/null 2>&1 || {
    echo -e "${RED}✗ Missing dependency:${RESET} $bin"
    echo "Install: pkg install $bin"
    exit 1
  }
done

echo -e "${CYAN}[1/5] Fetching GitHub org repos...${RESET}\n"
REPO_JSON="$FEED_DIR/repos_$(date +%Y%m%d_%H%M%S).json"
gh repo list "$ORG" --limit 500 --json name,url,description,updatedAt,defaultBranchRef,isPrivate,stargazerCount,forkCount,pushedAt | tee "$REPO_JSON" >/dev/null

REPO_COUNT="$(jq length "$REPO_JSON")"
echo -e "${GREEN}✓${RESET} Found $REPO_COUNT repositories"

echo -e "\n${CYAN}[2/5] Building feed_database.json...${RESET}\n"
FEED_DB="$FEED_DIR/feed_database.json"

cat > "$FEED_DB" <<'DB_START'
{
  "metadata": {
    "generated": "TIMESTAMP",
    "organization": "ORG_NAME",
    "domain": "DOMAIN_NAME",
    "total_projects": 0
  },
  "projects": [
DB_START

sed -i "s/TIMESTAMP/$(date -Iseconds)/" "$FEED_DB"
sed -i "s/ORG_NAME/$ORG/" "$FEED_DB"
sed -i "s/DOMAIN_NAME/$DOMAIN/" "$FEED_DB"
sed -i "s/\"total_projects\": 0/\"total_projects\": $REPO_COUNT/" "$FEED_DB"

jq -c '.[]' "$REPO_JSON" | while IFS= read -r repo; do
  NAME="$(echo "$repo" | jq -r '.name')"
  DESC="$(echo "$repo" | jq -r '.description // "No description"')"
  URL="$(echo "$repo" | jq -r '.url')"
  UPDATED="$(echo "$repo" | jq -r '.
