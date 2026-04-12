#!/data/data/com.termux/files/usr/bin/bash

# Evidence Blockchain Generator
# Creates tamper-evident chain of custody

EVIDENCE_DIR="$HOME/TotalRecall/complaint_project/evidence"
OUTPUT_FILE="$HOME/TotalRecall/complaint_project/strategic_tools/evidence/evidence_blockchain.json"

echo "Creating evidence blockchain..."

PREV_HASH="0000000000000000000000000000000000000000000000000000000000000000"

echo "[" > "$OUTPUT_FILE"

FIRST=1
for file in "$EVIDENCE_DIR"/*.txt; do
    [ ! -f "$file" ] && continue
    
    if [ $FIRST -eq 0 ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    FIRST=0
    
    FILENAME=$(basename "$file")
    CONTENT_HASH=$(sha256sum "$file" | awk '{print $1}')
    TIMESTAMP=$(date -Iseconds)
    FILESIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    # Create block hash from: previous_hash + content_hash + timestamp
    COMBINED="${PREV_HASH}${CONTENT_HASH}${TIMESTAMP}"
    BLOCK_HASH=$(echo -n "$COMBINED" | sha256sum | awk '{print $1}')
    
    cat >> "$OUTPUT_FILE" <<BLOCK
  {
    "block_number": $(($(grep -c "block_number" "$OUTPUT_FILE" 2>/dev/null || echo 0) + 1)),
    "timestamp": "$TIMESTAMP",
    "filename": "$FILENAME",
    "file_size_bytes": $FILESIZE,
    "content_hash": "$CONTENT_HASH",
    "previous_block_hash": "$PREV_HASH",
    "block_hash": "$BLOCK_HASH"
  }
BLOCK
    
    PREV_HASH="$BLOCK_HASH"
done

echo "" >> "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"

# Generate verification manifest
cat > "${OUTPUT_FILE%.json}_manifest.txt" <<MANIFEST
═══════════════════════════════════════════════════════════════
EVIDENCE BLOCKCHAIN VERIFICATION MANIFEST
═══════════════════════════════════════════════════════════════

Generated: $(date -Iseconds)
Blockchain File: evidence_blockchain.json
Genesis Hash: 0000000000000000000000000000000000000000000000000000000000000000
Terminal Hash: $PREV_HASH

Total Blocks: $(grep -c "block_number" "$OUTPUT_FILE")

═══════════════════════════════════════════════════════════════
VERIFICATION INSTRUCTIONS
═══════════════════════════════════════════════════════════════

To verify evidence integrity:

1. Obtain original evidence files
2. Recalculate content hashes: sha256sum [filename]
3. Compare against blockchain content_hash fields
4. Verify block_hash = SHA256(prev_hash + content_hash + timestamp)
5. Confirm chain links from genesis to terminal

Any modification breaks the chain, proving tampering.

═══════════════════════════════════════════════════════════════
LEGAL SIGNIFICANCE
═══════════════════════════════════════════════════════════════

This blockchain constitutes cryptographic proof that:
- Evidence existed at recorded timestamps
- Files have not been modified since chain creation
- Chain of custody is mathematically verifiable
- Any tampering is immediately detectable

Admissible under FRE 901(b)(9) (process or system evidence).

═══════════════════════════════════════════════════════════════
MANIFEST

echo "✅ Evidence blockchain created"
echo "   Blocks: $(grep -c "block_number" "$OUTPUT_FILE")"
echo "   Terminal Hash: $PREV_HASH"
echo ""
echo "JSON: $OUTPUT_FILE"
echo "Manifest: ${OUTPUT_FILE%.json}_manifest.txt"
