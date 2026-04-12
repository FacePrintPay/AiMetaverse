#!/data/data/com.termux/files/usr/bin/bash
echo "════════════════════════════════════════════════════════════════"
echo "📦 REBUILDING FINAL PACKAGE"
echo "════════════════════════════════════════════════════════════════"
cd ~/TotalRecall/complaint_project/strategic_tools/damages || exit 1
FILE="damages_report.json"
OUT="~/TotalRecall/complaint_project/FINAL_PACKAGE"
mkdir -p ~/TotalRecall/complaint_project/FINAL_PACKAGE
cp ~/TotalRecall/complaint_project/strategic_tools/damages/* ~/TotalRecall/complaint_project/FINAL_PACKAGE/
echo "✅ Damages calculator + report copied to FINAL_PACKAGE"
ls -lh ~/TotalRecall/complaint_project/FINAL_PACKAGE/
echo "════════════════════════════════════════════════════════════════"
echo "Done."
