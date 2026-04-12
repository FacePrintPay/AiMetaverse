 #!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="$HOME/TOTAL_RECALL_FINDINGS.txt"
NOW="$(date -Iseconds)"

SEARCH_DIRS=(
  "$HOME/scripts"
  "$HOME/packages"
  "$HOME/totalrecall"
  "$HOME/total_recall_runs"
  "$HOME/totalrecall_output"
  "$HOME/obsidian"
)

KEYWORDS="total[_-]?recall|1basher|forensic|denial|agent|agi|kre8tive|z[_-]?series"

echo "TOTAL RECALL — FILESYSTEM FORENSIC SUMMARY" > "$REPORT"
echo "Generated: $NOW" >> "$REPORT"
echo "Host: Termux ($(uname -a))" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "" >> "$REPORT"

echo "## 1) Directories inspected" >> "$REPORT"
for d in "${SEARCH_DIRS[@]}"; do
  [ -d "$d" ] && echo "- $d" >> "$REPORT"
done
echo "" >> "$REPORT"

echo "## 2) Recently modified relevant files (last 90 days)" >> "$REPORT"
find "${SEARCH_DIRS[@]}" -type f \
  \( -iname "*.sh" -o -iname "*.py" -o -iname "*.log" -o -iname "*.md" -o -iname "*.txt" \) \
  -mtime -90 \
  -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' 2>/dev/null \
  | sort >> "$REPORT"
echo "" >> "$REPORT"

echo "## 3) Keyword correlation scan" >> "$REPORT"
find "${SEARCH_DIRS[@]}" -type f \
  \( -iname "*.sh" -o -iname "*.py" -o -iname "*.log" -o -iname "*.md" -o -iname "*.txt" \) \
  -exec grep -IlE "$KEYWORDS" {} \; 2>/dev/null \
  | sort >> "$REPORT"
echo "" >> "$REPORT"

echo "## 4) Earliest observed Total Recall–related artifact" >> "$REPORT"
find "${SEARCH_DIRS[@]}" -type f \
  -exec grep -IlE "$KEYWORDS" {} \; 2>/dev/null \
  -exec stat -c '%y %n' {} \; \
  | sort | head -1 >> "$REPORT"
echo "" >> "$REPORT"

echo "## 5) Temporal clustering (files created within 14-day windows)" >> "$REPORT"
find "${SEARCH_DIRS[@]}" -type f \
  \( -iname "*.sh" -o -iname "*.py" -o -iname "*.log" \) \
  -printf '%TY-%Tm-%Td %p\n' 2>/dev/null \
  | sort \
  | awk '
    NR==1 {start=$1; group=start}
    {
      cmd="date -d \""$1"\" +%s"
      cmd | getline t
      close(cmd)
      if (NR==1) prev=t
      if ((t-prev) <= 1209600) {
        print "[CLUSTER]", $0
      } else {
        print ""
        print "[NEW WINDOW]", $0
      }
      prev=t
    }' >> "$REPORT"
echo "" >> "$REPORT"

echo "## 6) Summary (non-interpretive)" >> "$REPORT"
echo "- This report reflects **filesystem-backed timestamps only**." >> "$REPORT"
echo "- No execution, monitoring, ingestion, or attribution is asserted." >> "$REPORT"
echo "- Correlation is temporal and lexical only." >> "$REPORT"
echo "- Independent verification is required for legal or forensic use." >> "$REPORT"
echo "" >> "$REPORT"

echo "✔ DONE"
echo "Report written to:"
echo "$REPORT"
