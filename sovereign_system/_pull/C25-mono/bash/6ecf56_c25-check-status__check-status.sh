# REPO: c25-check-status | FILE: check-status.sh | CONSTELLATION25

#!/bin/bash
# Check status of all Vercel deployments
echo "🔍 CHECKING VERCEL DEPLOYMENT STATUS"
echo "====================================="
echo ""
PROJECTS_DIR="$HOME/kre8tive-empire/vercel-master/projects"
for project_dir in "$PROJECTS_DIR"/*; do
    project=$(basename "$project_dir")
    cd "$project_dir"
    echo "📦 $project"
    # Get deployment URL
    URL=$(vercel ls --prod 2>/dev/null | grep 'Ready' | head -1 | awk '{print $2}')
    if [ -n "$URL" ]; then
        # Check HTTP status
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$URL")
        if [ "$STATUS" = "200" ]; then
            echo "  ✅ $URL - OK ($STATUS)"
        else
            echo "  ❌ $URL - ERROR ($STATUS)"
        fi
    else
        echo "  ⚠️  No deployment found"
    fi
    echo ""
done
