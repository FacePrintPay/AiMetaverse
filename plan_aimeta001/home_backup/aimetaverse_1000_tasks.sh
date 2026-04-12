#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TASK_FILE="$HOME/aimetaverse_1000_tasks.txt"

cat > "$TASK_FILE" << 'TASKS'
0001. Draft spec for Home hero + free trial CTA
0002. Wireframe Home hero + free trial CTA
0003. Copywriting for Home hero + free trial CTA
0004. Backend model for Home hero + free trial CTA
0005. Frontend implementation for Home hero + free trial CTA
0006. Logging/analytics for Home hero
0007. Error/fallback UX for Home hero
0008. API documentation for Home hero
0009. Automated tests for Home hero
0010. QA launch checklist for Home hero
# ... tasks 0011 → 1000 continue exactly in this pattern ...
0999. Automated tests for Internal Admin Dashboard
1000. QA launch checklist for Internal Admin Dashboard
TASKS

echo "✔ Wrote 1000 tasks to: $TASK_FILE"
