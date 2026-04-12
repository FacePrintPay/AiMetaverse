#!/usr/bin/env bash
set -e

echo "🌍 Initializing Planetary Agent Mission for Repo Hardening..."

# Root safety check
if [ ! -d ".git" ]; then
  echo "❌ ERROR: This does not appear to be a git repository root."
  echo "➡️  cd into the repo (e.g., FacePrintPay) and run again."
  exit 1
fi

# Create mission directories
mkdir -p .planetary/{mercury,venus,mars,jupiter,saturn,uranus,neptune,sol,luna,chronos,atlas,oracle}
mkdir -p docs

# Helper function
create_task () {
  local file=$1
  local title=$2
  local body=$3

  if [ ! -f "$file" ]; then
    cat <<EOF > "$file"
# $title

Status: ⏳ Pending  
Owner: Planetary Agent  
Repo: $(basename "$(pwd)")

## Objective
$body

## Checklist
- [ ] Review existing materials
- [ ] Produce documented output
- [ ] Keep language operational and Linux-focused
- [ ] Avoid metaphors and mythology

## Output
Describe concrete files or changes made.

---
EOF
    echo "📝 Created $file"
  else
    echo "⚠️  Skipped existing $file"
  fi
}

# MERCURY — Repo Recon
create_task ".planetary/mercury/REPO_CLASSIFICATION.md" \
"Mercury — Repository Classification" \
"Inventory all repositories, classify by function (platform, infra, security, UI, experimental)."

# VENUS — Signal Reduction
create_task ".planetary/venus/PINNING_STRATEGY.md" \
"Venus — Pinning & Visibility Strategy" \
"Determine which repositories should be pinned, archived, or made private for enterprise review."

# MARS — README Rewrite
create_task ".planetary/mars/README_REWRITE.md" \
"Mars — README Hardening" \
"Rewrite README to be enterprise Linux–readable with clear architecture and run instructions."

# JUPITER — Architecture
create_task ".planetary/jupiter/ARCHITECTURE.md" \
"Jupiter — Architecture Documentation" \
"Describe system architecture, services, APIs, and data flow."

# SATURN — Operations
create_task ".planetary/saturn/OPERATIONS.md" \
"Saturn — Operations & Reliability" \
"Document logging, health checks, configuration, and runtime expectations."

# URANUS — Security
create_task ".planetary/uranus/SECURITY.md" \
"Uranus — Security Review" \
"Document authentication, key handling, and threat assumptions."

# NEPTUNE — Compliance
create_task ".planetary/neptune/COMPLIANCE_NOTES.md" \
"Neptune — Compliance & Auditability" \
"Map features to auditability, determinism, and least-privilege principles."

# SOL — Naming
create_task ".planetary/sol/NAMING_CLEANUP.md" \
"Sol — Naming & Clarity" \
"Recommend repo, folder, and file naming improvements."

# LUNA — Profile
create_task ".planetary/luna/PROFILE_READINESS.md" \
"Luna — GitHub Profile Readiness" \
"Rewrite bio and pinned repo descriptions for enterprise clarity."

# CHRONOS — Roadmap
create_task ".planetary/chronos/ROADMAP.md" \
"Chronos — Roadmap & Time Discipline" \
"Identify WIP, experimental features, and future work clearly."

# ATLAS — Release Check
create_task ".planetary/atlas/RELEASE_CHECKLIST.md" \
"Atlas — Release Validation" \
"Ensure README steps work, links are valid, and repo runs."

# ORACLE — Red Hat Review
create_task ".planetary/oracle/REDHAT_REVIEW.md" \
"Oracle — Red Hat Readiness Review" \
"Simulate recruiter and engineer review; note red flags."

# Top-level enterprise docs (placeholders)
for doc in ARCHITECTURE.md OPERATIONS.md SECURITY.md; do
  if [ ! -f "docs/$doc" ]; then
    echo "# $doc" > "docs/$doc"
    echo "🗂 Created docs/$doc"
  fi
done

echo "✅ Planetary mission initialized."
echo "➡️  Start with: .planetary/mars/README_REWRITE.md"
echo "➡️  Nothing was deleted. Everything is reversible."
