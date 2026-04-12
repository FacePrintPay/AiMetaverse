#!/data/data/com.termux/files/usr/bin/bash

# ═══════════════════════════════════════════════════════════════════════
# TOTAL RECALL - DENIAL IMAGE ANALYSIS
# Deep forensic analysis of denial_1.png and denial_2.png
# ═══════════════════════════════════════════════════════════════════════

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
RESET='\033[0m'

IMG1="$HOME/total_recall_runs/input/denial_1.png"
IMG2="$HOME/total_recall_runs/input/denial_2.png"

OUTPUT="$HOME/denial_images_analysis_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "═══════════════════════════════════════════════════════════"
    echo "TOTAL RECALL - DENIAL IMAGES FORENSIC ANALYSIS"
    echo "Analysis Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "═══════════════════════════════════════════════════════════"
    
    for IMG in "$IMG1" "$IMG2"; do
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "ANALYZING: $(basename "$IMG")"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if [ ! -f "$IMG" ]; then
            echo "⚠️  FILE NOT FOUND: $IMG"
            continue
        fi
        
        echo ""
        echo "[FILE STATISTICS]"
        stat "$IMG"
        
        echo ""
        echo "[FILE HASH - SHA256]"
        sha256sum "$IMG" | awk '{print $1}'
        
        echo ""
        echo "[FILE HASH - MD5]"
        md5sum "$IMG" | awk '{print $1}'
        
        echo ""
        echo "[FILE SIZE]"
        ls -lh "$IMG" | awk '{print $5}'
        
        echo ""
        echo "[FILE TYPE]"
        file "$IMG"
        
        # If exiftool is available
        if command -v exiftool >/dev/null 2>&1; then
            echo ""
            echo "[EXIF METADATA]"
            exiftool "$IMG"
        fi
        
        # Check if file contains any text strings
        echo ""
        echo "[EMBEDDED TEXT STRINGS]"
        strings "$IMG" | grep -E "[a-zA-Z]{4,}" | head -20
        
        # If imagemagick is available
        if command -v identify >/dev/null 2>&1; then
            echo ""
            echo "[IMAGE PROPERTIES]"
            identify -verbose "$IMG" | head -30
        fi
        
    done
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "COMPARISON ANALYSIS"
    echo "═══════════════════════════════════════════════════════════"
    
    if [ -f "$IMG1" ] && [ -f "$IMG2" ]; then
        SIZE1=$(stat -c%s "$IMG1" 2>/dev/null)
        SIZE2=$(stat -c%s "$IMG2" 2>/dev/null)
        
        echo ""
        echo "File Size Comparison:"
        echo "  denial_1.png: $SIZE1 bytes"
        echo "  denial_2.png: $SIZE2 bytes"
        echo "  Difference: $((SIZE2 - SIZE1)) bytes"
        
        echo ""
        echo "Timestamp Comparison:"
        echo "  denial_1.png modified: $(stat -c%y "$IMG1")"
        echo "  denial_2.png modified: $(stat -c%y "$IMG2")"
        
        echo ""
        echo "Hash Verification:"
        echo "  denial_1.png SHA256: $(sha256sum "$IMG1" | awk '{print $1}')"
        echo "  denial_2.png SHA256: $(sha256sum "$IMG2" | awk '{print $1}')"
        
        if [ "$SIZE1" -eq "$SIZE2" ]; then
            echo ""
            echo "⚠️  WARNING: Files are identical in size - checking if duplicate..."
            HASH1=$(sha256sum "$IMG1" | awk '{print $1}')
            HASH2=$(sha256sum "$IMG2" | awk '{print $1}')
            if [ "$HASH1" = "$HASH2" ]; then
                echo "🚨 CRITICAL: Files are IDENTICAL (same hash)"
            fi
        fi
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "EVIDENCE CHAIN OF CUSTODY"
    echo "═══════════════════════════════════════════════════════════"
    echo "Evidence Location: ~/total_recall_runs/input/"
    echo "Analysis Report: $OUTPUT"
    echo "Analyst: Total Recall Forensic Engine"
    echo "Integrity Hash: $(cat "$OUTPUT" 2>/dev/null | sha256sum | awk '{print $1}' || echo 'pending')"
    
} | tee "$OUTPUT"

echo ""
echo -e "${GREEN}✓ Analysis complete!${RESET}"
echo -e "Full report saved to: ${CYAN}$OUTPUT${RESET}"

# If OCR is available, run it
if command -v tesseract >/dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}Running OCR on denial images...${RESET}"
    
    for IMG in "$IMG1" "$IMG2"; do
        if [ -f "$IMG" ]; then
            OCR_OUT="$HOME/$(basename "$IMG" .png)_ocr.txt"
            echo -e "  Extracting text from $(basename "$IMG")..."
            tesseract "$IMG" "${OCR_OUT%.txt}" 2>/dev/null && \
                echo -e "${GREEN}  ✓ Text extracted to: $OCR_OUT${RESET}" || \
                echo -e "${RED}  ✗ OCR failed for $(basename "$IMG")${RESET}"
        fi
    done
fi

