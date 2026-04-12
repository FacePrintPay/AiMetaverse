#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# YesQuid - HEMPCONCHOICES PASS 2
# Inventory & project map for code_recovery
# ==========================================================
set -euo pipefail

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

ROOT="$HOME/YesQuidExtracts/hempchoices_stage/code_recovery"
OUT="$HOME/YesQuidExtracts/hempchoices_stage/inventory"

mkdir -p "$OUT"

echo -e "${CYAN}==========================================${RESET}"
echo -e "${CYAN}  HEMPCHOICES PASS 2 - INVENTORY SCAN     ${RESET}"
echo -e "${CYAN}==========================================${RESET}"
echo "[*] Root : $ROOT"
echo "[*] Out  : $OUT"
echo

# 1) Top-level directories snapshot
echo "[*] Writing dirs_top_3.txt ..."
find "$ROOT" -maxdepth 3 -type d > "$OUT/dirs_top_3.txt"

# 2) Node / JS / TS projects
echo "[*] Finding Node/TS projects ..."
find "$ROOT" -name "package.json"      >  "$OUT/node_projects.txt"
find "$ROOT" -name "next.config.*"    >> "$OUT/node_projects.txt"
find "$ROOT" -name "tsconfig.json"    >> "$OUT/node_projects.txt"
find "$ROOT" -name "vite.config.*"    >> "$OUT/node_projects.txt"

# 3) Python projects
echo "[*] Finding Python projects ..."
find "$ROOT" -name "requirements.txt" >  "$OUT/python_projects.txt"
find "$ROOT" -name "pyproject.toml"   >> "$OUT/python_projects.txt"
find "$ROOT" -name "Pipfile"         >> "$OUT/python_projects.txt"

# 4) JVM / Android / Gradle
echo "[*] Finding Gradle / Java / Android ..."
find "$ROOT" -name "build.gradle*"    >  "$OUT/gradle_projects.txt"
find "$ROOT" -name "settings.gradle*" >> "$OUT/gradle_projects.txt"
find "$ROOT" -name "AndroidManifest.xml" >> "$OUT/gradle_projects.txt"

# 5) Go / Rust / others
echo "[*] Finding Go / Rust / misc ..."
find "$ROOT" -name "go.mod"           >  "$OUT/go_rust_misc.txt"
find "$ROOT" -name "Cargo.toml"      >> "$OUT/go_rust_misc.txt"
find "$ROOT" -name "Dockerfile"      >> "$OUT/go_rust_misc.txt"
find "$ROOT" -name "*.dockerfile"    >> "$OUT/go_rust_misc.txt"

# 6) Direct AiMetaVerse / Total Recall / Planetary references
echo "[*] Grepping for AiMetaVerse / Total Recall / Planetary Agents ..."
grep -RIl --null \
  -e "AiMetaVerse" \
  -e "aimetaverse-d40f4" \
  -e "Total Recall" \
  -e "TOTAL RECALL" \
  -e "Planetary Agent" \
  -e "SovereignVault" \
  -e "FacePrintPay" \
  -e "AiRecords" \
  "$ROOT" \
  | tr '\0' '\n' > "$OUT/core_brands_hits.txt" || true

# 7) Quick stats
echo "[*] Counting total files in code_recovery ..."
find "$ROOT" -type f | wc -l > "$OUT/file_count.txt"

echo
echo -e "${GREEN}[✓] PASS 2 INVENTORY COMPLETE${RESET}"
echo "[*] Inventory dir: $OUT"
echo "[*] Key files:"
echo "    - dirs_top_3.txt"
echo "    - node_projects.txt"
echo "    - python_projects.txt"
echo "    - gradle_projects.txt"
echo "    - go_rust_misc.txt"
echo "    - core_brands_hits.txt"
echo "    - file_count.txt"
