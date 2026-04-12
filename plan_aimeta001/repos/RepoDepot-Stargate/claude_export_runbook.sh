#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# CLAUDE (Anthropic) EXPORT RUNBOOK GENERATOR — TERMUX SAFE
# Creates an export folder + manifests + repo skeleton helper.
# NOTE: Actual chat export must be done via Claude UI / Data Export.
# ==========================================================

set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
BOLD='\033[1m'
RESET='\033[0m'

need() { command -v "$1" >/dev/null 2>&1 || return 1; }

clear
echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║   CLAUDE CONVERSATION EXPORT RUNBOOK      ║${RESET}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════╝${RESET}\n"

STAMP="$(date +%Y%m%d_%H%M%S)"
EXPORT_DIR="${EXPORT_DIR:-$HOME/anthropic-export-$STAMP}"
REMOTE_UPLOAD="${REMOTE_UPLOAD:-}"   # example: r2:sovereignvault/claude_exports/
ZIP_AFTER="${ZIP_AFTER:-1}"          # 1=yes 0=no

mkdir -p "$EXPORT_DIR"/{artifacts,conversations,notes}

# Basic deps (optional)
MISSING=()
for b in git; do
  need "$b" || MISSING+=("$b")
done

# zip is optional but nice
if ! need zip; then
  echo -e "${YELLOW}⚠ zip not found.${RESET} If you want zips: pkg install zip"
fi

# rclone optional
if [ -n "$REMOTE_UPLOAD" ] && ! need rclone; then
  echo -e "${RED}✗ rclone not found but REMOTE_UPLOAD is set.${RESET}"
  echo "Install: pkg install rclone"
  exit 1
fi

cat > "$EXPORT_DIR/MANIFEST.md" <<EOF
# Claude Export Runbook (Anthropic)

Generated: $(date)

## What this folder is
This is a **local export workspace** for backing up:
- Claude conversation exports (downloaded via Claude UI)
- Claude account full data export (requested from settings)
- Any artifacts you manually copy/download

## Where to export from Claude
### Export a single conversation
1. Open Claude in browser: https://claude.ai
2. Open the conversation you want
3. Menu (⋯) → **Export conversation** (Markdown/JSON)
4. Save into:
   - $EXPORT_DIR/conversations/

### Request your full data export (all conversations)
1. Go to: https://claude.ai/settings
2. Privacy & Data → **Request data export**
3. Save the delivered ZIP into:
   - $EXPORT_DIR/conversations/

## Local folders
- conversations/  → exported .md/.json or full export zip
- artifacts/      → any downloaded artifacts
- notes/          → your hand notes or evidence memos

## Optional: turn this into a GitHub repo
Run:
  bash $EXPORT_DIR/create_github_repo.sh

EOF

# Your artifacts list (editable)
cat > "$EXPORT_DIR/artifact_list.txt" <<'ARTIFACTS'
ARTIFACTS FROM THIS SESSION (EDIT ME)
===================================

Add any items you want to track here (names + where stored).

Example:
1) Coding standards (YesQuid)
2) Deployment scripts
3) Agent orchestrators
4) Portfolio HTML builds

ARTIFACTS

# Repo skeleton helper
cat > "$EXPORT_DIR/create_github_repo.sh" <<'REPO_SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_NAME="${REPO_NAME:-claude-artifacts-export}"
REPO_DIR="$HOME/$REPO_NAME"

echo "Creating repo folder: $REPO_DIR"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

git init >/dev/null

mkdir -p scripts docs exports/{conversations,artifacts} config .github/workflows

cat > README.md <<'README'
# Claude Export Vault

This repo stores exported Claude conversations, artifacts, and supporting notes.

## Layout
- exports/conversations/  → exported Markdown/JSON and/or full export zips
- exports/artifacts/      → downloaded artifacts
- docs/                   → notes, summaries, indexes
- scripts/                → helper scripts

## How to add exports
Copy files into exports/ then commit + push.

README

echo "✅ Repo skeleton ready at: $REPO_DIR"
echo "Next: copy your export files into exports/, then commit + push."
REPO_SCRIPT

chmod +x "$EXPORT_DIR/create_github_repo.sh"

# Convenience “where to click” cheat sheet
cat > "$EXPORT_DIR/notes/QUICK_STEPS.txt" <<EOF
CLAUDE EXPORT QUICK STEPS
========================

1) Export THIS conversation:
- Open in browser (claude.ai)
- (⋯) menu → Export conversation (Markdown/JSON)
- Save file into:
  $EXPORT_DIR/conversations/

2) Request FULL account export:
- https://claude.ai/settings → Privacy & Data → Request data export
- When email arrives, download zip and store in:
  $EXPORT_DIR/conversations/

3) Artifacts:
- Download/copy artifact content → save into:
  $EXPORT_DIR/artifacts/

EOF

echo -e "${GREEN}✓${RESET} Created export workspace: $EXPORT_DIR"
echo "Contents:"
ls -la "$EXPORT_DIR" | sed 's/^/  /'

# Optional zip
if [ "${ZIP_AFTER}" = "1" ] && need zip; then
  echo -e "\n${CYAN}Zipping export folder...${RESET}"
  cd "$(dirname "$EXPORT_DIR")"
  ZIP_NAME="$(basename "$EXPORT_DIR").zip"
  zip -r "$ZIP_NAME" "$(basename "$EXPORT_DIR")" >/dev/null
  echo -e "${GREEN}✓${RESET} Zip created: $(pwd)/$ZIP_NAME"

  # Optional upload
  if [ -n "$REMOTE_UPLOAD" ]; then
    echo -e "\n${CYAN}Uploading zip via rclone...${RESET}"
    rclone copy -P "$ZIP_NAME" "$REMOTE_UPLOAD"
    echo -e "${GREEN}✓${RESET} Uploaded to: $REMOTE_UPLOAD"
  fi
fi

echo -e "\n${CYAN}${BOLD}Done.${RESET}"
echo -e "${YELLOW}Reminder:${RESET} Claude exports happen in the Claude UI or via full data export request."
