#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$HOME/Kre8tiveKonceptz_RepoDepo}"
ARTIFACTS_DIR="$REPO_ROOT/artifacts"
INCOMING="$REPO_ROOT/incoming"
LOGDIR="$REPO_ROOT/logs"
LOG="$LOGDIR/repodepo_integrate_v3.log"

EXPORT_ROOT="${EXPORT_ROOT:-$HOME}"   # scans ~/anthropic-export-* by default too

mkdir -p "$ARTIFACTS_DIR" "$INCOMING" "$LOGDIR"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  RepoDepo Harvest + Integrate v3 (NO STUBS)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo "" | tee "$LOG"

if [[ ! -d "$REPO_ROOT" ]]; then
  echo -e "${YELLOW}[WARN]${NC} RepoDepo not initialized at: $REPO_ROOT" | tee -a "$LOG"
  exit 1
fi

hash_file(){ sha256sum "$1" | awk '{print $1}'; }

looks_like_code () {
  rg -q "(#!/|function |case |import |export |class |def |=>|module\.exports|BEGIN:VEVENT|<html|<script)" "$1" 2>/dev/null
}

# ---------- 1) HARVEST ----------
echo -e "${BLUE}[1/2]${NC} Harvesting Anthropic exports + code files into incoming/ ..." | tee -a "$LOG"
EXT_REGEX='\.(sh|py|js|ts|jsx|tsx|json|ya?ml|md|txt|env|toml|ini|conf)$'

found=0; copied=0; dup=0
while IFS= read -r -d '' file; do
  [[ "$file" =~ $EXT_REGEX ]] || continue

  # skip tiny junk
  size="$(stat -c%s "$file" 2>/dev/null || echo 0)"
  [[ "$size" -lt 120 ]] && continue

  ext="${file##*.}"
  if [[ "$ext" == "txt" ]]; then
    looks_like_code "$file" || continue
  fi

  found=$((found+1))
  sum="$(hash_file "$file")"
  base="$(basename "$file")"
  dest="$INCOMING/${sum}_${base}"

  if [[ -f "$dest" ]]; then
    dup=$((dup+1))
    continue
  fi

  cp -f "$file" "$dest"
  chmod 700 "$dest" 2>/dev/null || true
  copied=$((copied+1))
done < <(find "$EXPORT_ROOT" -type f -print0 2>/dev/null)

echo "Harvested files scanned: $found" | tee -a "$LOG"
echo "Copied new into incoming/: $copied (dupes skipped: $dup)" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ---------- 2) INTEGRATE ----------
echo -e "${BLUE}[2/2]${NC} Integrating incoming/ → artifacts/ (NO overwrites) ..." | tee -a "$LOG"

mkdir -p \
  "$ARTIFACTS_DIR/01_yesquid_pathos" \
  "$ARTIFACTS_DIR/02_state_management" \
  "$ARTIFACTS_DIR/03_cloud_integration" \
  "$ARTIFACTS_DIR/04_videocourts" \
  "$ARTIFACTS_DIR/05_tools_utilities" \
  "$ARTIFACTS_DIR/06_documentation" \
  "$ARTIFACTS_DIR/07_portfolio_html" \
  "$ARTIFACTS_DIR/08_playwright" \
  "$ARTIFACTS_DIR/99_misc"

classify () {
  local f="$1"
  local name
  name="$(basename "$f" | tr '[:upper:]' '[:lower:]')"

  if rg -qi "yesquid|pathos|sovereignvault|send2repo" "$f" 2>/dev/null || [[ "$name" =~ yesquid|pathos ]]; then
    echo "01_yesquid_pathos"; return
  fi
  if rg -qi "state|checksum|build state" "$f" 2>/dev/null || [[ "$name" =~ state|checksum ]]; then
    echo "02_state_management"; return
  fi
  if rg -qi "rclone|gsutil|gcs|cloudflare|r2|s3|bucket|vercel" "$f" 2>/dev/null || [[ "$name" =~ rclone|gcs|r2|s3|cloud|vercel ]]; then
    echo "03_cloud_integration"; return
  fi
  if rg -qi "videocourt|case deployment|blockchain timestamp" "$f" 2>/dev/null || [[ "$name" =~ videocourt|deploy_case ]]; then
    echo "04_videocourts"; return
  fi
  if rg -qi "<!doctype html|<html|<script|tailwind|portfolio|catalog|thumbnail" "$f" 2>/dev/null || [[ "$name" =~ html|portfolio|catalog ]]; then
    echo "07_portfolio_html"; return
  fi
  if rg -qi "playwright|chromium|page\.goto|browser\.newPage" "$f" 2>/dev/null || [[ "$name" =~ playwright ]]; then
    echo "08_playwright"; return
  fi
  if [[ "$name" =~ \.md$ ]]; then
    echo "06_documentation"; return
  fi
  if rg -qi "find_code_files|md5sum|sha256sum|utility|tools" "$f" 2>/dev/null || [[ "$name" =~ tool|util|finder ]]; then
    echo "05_tools_utilities"; return
  fi

  echo "99_misc"
}

moved=0; skipped=0

shopt -s nullglob
for f in "$INCOMING"/*; do
  [[ -f "$f" ]] || continue
  catdir="$(classify "$f")"
  destdir="$ARTIFACTS_DIR/$catdir"
  mkdir -p "$destdir"

  base="$(basename "$f")"
  dest="$destdir/$base"

  # never overwrite existing artifact file
  if [[ -f "$dest" ]]; then
    skipped=$((skipped+1))
    continue
  fi

  cp -n "$f" "$dest"
  chmod 700 "$dest" 2>/dev/null || true
  moved=$((moved+1))
done

echo "Integrated new artifacts: $moved" | tee -a "$LOG"
echo "Skipped existing (no overwrite): $skipped" | tee -a "$LOG"

echo ""
echo -e "${GREEN}✅ Done.${NC}"
echo "Artifacts root: $ARTIFACTS_DIR"
echo "Incoming stash: $INCOMING"
echo "Log: $LOG"
echo ""
echo "Quick sanity:"
echo "  find \"$ARTIFACTS_DIR\" -type f | wc -l"
