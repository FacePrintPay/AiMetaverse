#!/usr/bin/env bash
set -euo pipefail

START="${1:-$HOME}"

find "$START" -type f -name stack_up.sh 2>/dev/null | while read -r file; do
  root="$(dirname "$file")"
  echo "$root"
  exit 0
done

echo "❌ MONOREPO NOT FOUND"
exit 1
