#!/data/data/com.termux/files/usr/bin/bash

# TOTAL RECALL | 24HR ONE-BASH - FIXED VERSION
# Handles permission issues and provides fallbacks

echo "🚀 Launching 24HR RE-RUN sequence (Fixed)..."

# Flexible vault location
if [ -d "$HOME/SovereignVault" ] && [ -w "$HOME/SovereignVault" ]; then
    VAULT_DIR="$HOME/SovereignVault"
else
    VAULT_DIR="$HOME/temp_vault"
    mkdir -p "$VAULT_DIR"/{logs,html_outputs}
    echo "⚠️ Using temporary vault: $VAULT_DIR"
fi

LOG_DIR="$VAULT_DIR/logs/$(date +%Y%m%d_%H%M)"
HTML_DIR="$VAULT_DIR/html_outputs"

# Create directories with error handling
mkdir -p "$LOG_DIR" "$HTML_DIR" || {
    echo "❌ Failed to create directories, using /tmp"
    LOG_DIR="/tmp/total_recall_$(date +%Y%m%d_%H%M)"
    HTML_DIR="/tmp/html_outputs"
    mkdir -p "$LOG_DIR" "$HTML_DIR"
}

echo "📂 Using LOG_DIR: $LOG_DIR"
echo "📂 Using HTML_DIR: $HTML_DIR"

echo "📦 Gathering executable .sh scripts from last 24 hours..."

# Find scripts more safely
SCRIPT_LIST="$LOG_DIR/scripts_to_run.txt"
find "$HOME" -type f -name "*.sh" -mtime -1 2>/dev/null > "$SCRIPT_LIST" || {
    echo "Using alternative script discovery..."
    find "$HOME/agents" -name "*.sh" -type f 2>/dev/null > "$SCRIPT_LIST"
}

# Run each script
RUN_INDEX=0
while IFS= read -r SCRIPT; do
    if [ -f "$SCRIPT" ] && [ -x "$SCRIPT" ]; then
        ((RUN_INDEX++))
        OUTFILE="$LOG_DIR/output_$RUN_INDEX.log"
        
        echo "▶️ Running: $SCRIPT"
        echo "=== Script: $SCRIPT - $(date) ===" > "$OUTFILE"
        
        # Run with timeout to prevent hanging
        timeout 300 bash "$SCRIPT" >> "$OUTFILE" 2>&1 || echo "Script timed out or failed" >> "$OUTFILE"
        echo "✅ Completed: $SCRIPT" >> "$OUTFILE"
    fi
done < "$SCRIPT_LIST"

# Generate consolidated HTML report
CONSOLIDATED_HTML="$HTML_DIR/consolidated_report.html"

cat > "$CONSOLIDATED_HTML" << HTMLEOF
<!DOCTYPE html>
<html>
<head>
    <title>🌌 Total Recall - 24HR Script Run</title>
    <style>
        body { 
            font-family: monospace; 
            background: #000; 
            color: #0f0; 
            margin: 20px;
            line-height: 1.4;
        }
        h1 { 
            color: #fff; 
            text-align: center; 
            border-bottom: 2px solid #0f0; 
            padding-bottom: 10px;
        }
        h2 { 
            color: #ff0; 
            border-left: 4px solid #0f0; 
            padding-left: 10px;
        }
        pre { 
            background: #111; 
            padding: 15px; 
            border: 1px solid #333; 
            overflow-x: auto;
            max-height: 400px;
            overflow-y: auto;
        }
        .stats {
            background: #001100;
            border: 1px solid #0f0;
            padding: 10px;
            margin: 20px 0;
        }
        hr { 
            border: none; 
            height: 2px; 
            background: #0f0; 
            margin: 30px 0;
        }
    </style>
</head>
<body>
    <h1>🌌 Total Recall - 24HR Script Run</h1>
    <div class="stats">
        <h3>📊 Run Statistics</h3>
        <p><strong>Timestamp:</strong> $(date)</p>
        <p><strong>Scripts Found:</strong> $(wc -l < "$SCRIPT_LIST")</p>
        <p><strong>Log Directory:</strong> $LOG_DIR</p>
        <p><strong>Vault Directory:</strong> $VAULT_DIR</p>
    </div>
    <hr>
HTMLEOF

# Add log contents
for LOG in "$LOG_DIR"/*.log; do
    if [ -f "$LOG" ]; then
        echo "<h2>📄 $(basename "$LOG")</h2>" >> "$CONSOLIDATED_HTML"
        echo "<pre>" >> "$CONSOLIDATED_HTML"
        
        # Limit file size to prevent huge HTML files
        if [ $(stat -c%s "$LOG" 2>/dev/null || echo 0) -gt 1048576 ]; then
            echo "[File truncated - showing last 1MB]" >> "$CONSOLIDATED_HTML"
            tail -c 1048576 "$LOG" | sed 's/</\&lt;/g; s/>/\&gt;/g' >> "$CONSOLIDATED_HTML"
        else
            sed 's/</\&lt;/g; s/>/\&gt;/g' "$LOG" >> "$CONSOLIDATED_HTML"
        fi
        
        echo "</pre><hr>" >> "$CONSOLIDATED_HTML"
    fi
done

echo "</body></html>" >> "$CONSOLIDATED_HTML"

echo "✅ Total Recall sequence complete!"
echo "📊 Generated report: $CONSOLIDATED_HTML"
echo "📂 Logs saved to: $LOG_DIR"

# Try to open the report
if command -v termux-open &> /dev/null; then
    echo "📂 Opening report..."
    termux-open "$CONSOLIDATED_HTML"
else
    echo "📍 Report available at: $CONSOLIDATED_HTML"
fi

# Show summary
echo ""
echo "🎉 Summary:"
echo "   Scripts executed: $(ls -1 "$LOG_DIR"/output_*.log 2>/dev/null | wc -l)"
echo "   Total log files: $(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)"
echo "   Report size: $(ls -lh "$CONSOLIDATED_HTML" 2>/dev/null | awk '{print $5}' || echo 'Unknown')"
