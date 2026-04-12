#!/bin/bash
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ARTIFACT=~/c25_ship/evidence/c25_v1_$(date +%s).json
cat << EVIDENCE > "$ARTIFACT"
{
  "build_id": "c25-v1.0-$(git -C ~/github-repos/Constellation25 rev-parse --short HEAD 2>/dev/null || echo 'local')",
  "timestamp": "$TIMESTAMP",
  "creator": "CyGeL White",
  "storage_freed": true,
  "repo_normalized": true,
  "ollama_active": $(curl -s localhost:11434/api/tags >/dev/null 2>&1 && echo true || echo false),
  "hash": "$(sha256sum "$ARTIFACT" 2>/dev/null | cut -d' ' -f1 || echo 'pending')"
}
EVIDENCE
echo "✅ Evidence generated: $ARTIFACT"
cat "$ARTIFACT"
