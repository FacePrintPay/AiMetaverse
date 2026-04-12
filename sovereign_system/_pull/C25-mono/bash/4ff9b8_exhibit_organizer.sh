#!/data/data/com.termux/files/usr/bin/bash

# Exhibit Organization and Labeling System

EVIDENCE_DIR="$HOME/TotalRecall/complaint_project/evidence"
EXHIBITS_DIR="$HOME/TotalRecall/complaint_project/exhibits_for_filing"

mkdir -p "$EXHIBITS_DIR"/{primary,z_series,supplemental}

echo "═══════════════════════════════════════════════════════════════"
echo "EXHIBIT ORGANIZATION SYSTEM"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Generate exhibit labels
cat > "$EXHIBITS_DIR/EXHIBIT_LABELS.txt" <<LABELS
═══════════════════════════════════════════════════════════════
EXHIBIT LABELS - WHITE v. GOOGLE LLC
═══════════════════════════════════════════════════════════════

Print these on legal exhibit tabs/stickers:

PRIMARY EXHIBITS (A-F):
┌────────────────────────────────────────────────────────────┐
│ EXHIBIT A │ OpenAI DSAR Response                           │
│ EXHIBIT B │ OpenAI DSAR Response (Duplicate)               │
│ EXHIBIT C │ EPIC FOIA Disclosure (Google Subpoena Protocol)│
│ EXHIBIT D │ Google Privacy Policy 2022-2023                │
│ EXHIBIT E │ Academic Paper: ToS Ambiguity Study            │
│ EXHIBIT F │ Forensic Extraction Summary                    │
└────────────────────────────────────────────────────────────┘

Z-SERIES CORE (Z-1 to Z-10):
┌────────────────────────────────────────────────────────────┐
│ EXHIBIT Z-1  │ [Complete vault listing]                    │
│ EXHIBIT Z-5  │ AI Ownership Admissions                     │
│ EXHIBIT Z-6  │ Legal Damages Summary                       │
│ EXHIBIT Z-23 │ Legacy Claim Affidavit                      │
│ EXHIBIT Z-29 │ Chain of Custody Record                     │
│ EXHIBIT Z-33 │ Starlake Incident Report (Sept 27, 2025)    │
└────────────────────────────────────────────────────────────┘

TODAY'S SUPPLEMENTS:
┌────────────────────────────────────────────────────────────┐
│ EXHIBIT Z-Today-1 │ Consolidated AI Admissions (Nov 8)     │
│ EXHIBIT Z-Today-2 │ Manifest Re-verification (Nov 8)       │
│ EXHIBIT IC3-Trace │ IC3 Bounce Report (Oct 5, 2025)        │
└────────────────────────────────────────────────────────────┘

FORENSIC BUNDLE:
┌────────────────────────────────────────────────────────────┐
│ EXHIBIT Bundle-20251107 │ Sealed Forensic Archive         │
│   - forensic_case_bundle_20251107_073352.tar.gz            │
│   - Includes hash_manifest.txt                             │
│   - Filed on USB drive under seal                          │
└────────────────────────────────────────────────────────────┘

NEW STRATEGIC EXHIBITS (Z-60 to Z-70):
┌────────────────────────────────────────────────────────────┐
│ EXHIBIT Z-60 │ Damages Calculation Report                  │
│ EXHIBIT Z-61 │ Feature Comparison Matrix                   │
│ EXHIBIT Z-62 │ Visual Timeline Graphic                     │
│ EXHIBIT Z-63 │ Compilation of AI Admissions                │
│ EXHIBIT Z-64 │ GCP Billing Statements (Annotated)          │
│ EXHIBIT Z-65 │ DSAR Denial Correspondence                  │
│ EXHIBIT Z-66 │ Retainer Agreement (Redacted)               │
│ EXHIBIT Z-67 │ Copyright Registration Application          │
│ EXHIBIT Z-68 │ Expert Witness Declarations (Preliminary)   │
│ EXHIBIT Z-69 │ Preservation Letters w/ Proof of Service    │
│ EXHIBIT Z-70 │ Video Evidence Demonstration (USB)          │
└────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
FILING INSTRUCTIONS
═══════════════════════════════════════════════════════════════

FOR PAPER FILING:
1. Print each exhibit
2. Attach exhibit label tab to top right corner
3. Three-hole punch on left side
4. Insert in binder with dividers
5. Create table of contents

FOR E-FILING:
1. PDF each exhibit separately
2. Name files: "Exhibit_A_OpenAI_DSAR.pdf"
3. Ensure OCR (text searchable)
4. Verify file size < 25MB per file
5. Create combined "Exhibits_A_through_F.pdf" if allowed
6. Upload to court's ECF portal

═══════════════════════════════════════════════════════════════
LABELS

cat "$EXHIBITS_DIR/EXHIBIT_LABELS.txt"

echo ""
echo "✅ Exhibit labels generated"
echo "   Location: $EXHIBITS_DIR/EXHIBIT_LABELS.txt"
