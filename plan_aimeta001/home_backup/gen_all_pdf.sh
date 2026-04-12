#!/data/data/com.termux/files/usr/bin/bash

# PDF Generation Script for Total Recall Reports
echo "📄 Generating PDF reports from HTML..."

# Check if wkhtmltopdf is available, if not install
if ! command -v wkhtmltopdf &> /dev/null; then
    echo "📦 Installing wkhtmltopdf..."
    pkg install wkhtmltopdf -y
fi

HTML_DIR="$HOME/SovereignVault/html_outputs"
PDF_DIR="$HOME/SovereignVault/pdf_outputs"
mkdir -p "$PDF_DIR"

# Convert main consolidated report to PDF
if [ -f "$HTML_DIR/consolidated_report.html" ]; then
    echo "🔄 Converting consolidated report to PDF..."
    wkhtmltopdf --enable-local-file-access \
                --page-size A4 \
                --margin-top 20mm \
                --margin-bottom 20mm \
                --margin-left 15mm \
                --margin-right 15mm \
                "$HTML_DIR/consolidated_report.html" \
                "$PDF_DIR/TotalRecall_$(date +%Y%m%d_%H%M%S).pdf"
    
    echo "✅ PDF generated: $PDF_DIR/TotalRecall_$(date +%Y%m%d_%H%M%S).pdf"
else
    echo "❌ No consolidated report found"
fi

# Convert individual HTML reports to PDF
for html_file in "$HTML_DIR"/*.html; do
    if [ -f "$html_file" ] && [[ "$html_file" != *"consolidated_report"* ]]; then
        filename=$(basename "$html_file" .html)
        echo "🔄 Converting $filename to PDF..."
        wkhtmltopdf --enable-local-file-access \
                    --page-size A4 \
                    "$html_file" \
                    "$PDF_DIR/${filename}_$(date +%Y%m%d_%H%M%S).pdf"
    fi
done

echo "🎉 All PDF generation complete!"
echo "📂 PDFs saved to: $PDF_DIR"
ls -la "$PDF_DIR"
