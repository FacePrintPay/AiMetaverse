#!/bin/bash
set -euo pipefail
# REPO: c25-cleanup-failed | FILE: cleanup-failed.sh | CONSTELLATION25

#!/bin/bash
# Remove failed deployments and redeploy
echo "🧹 CLEANING UP FAILED DEPLOYMENTS"
echo "=================================="
echo ""
PROJECTS_DIR="$HOME/kre8tive-empire/vercel-master/projects"
for project_dir in "$PROJECTS_DIR"/*; do
    project=$(basename "$project_dir")
    cd "$project_dir"
    # Check if deployment is working
    URL=$(vercel ls --prod 2>/dev/null | grep 'Ready' | head -1 | awk '{print $2}')
    if [ -n "$URL" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$URL")
        if [ "$STATUS" != "200" ]; then
            echo "🔄 Redeploying $project (current status: $STATUS)..."
            # Remove failed deployment
            vercel rm "$project" --yes --scope faceprintpay 2>/dev/null || true
            # Redeploy
            bash deploy.sh
            echo "✅ $project redeployed"
        fi
    else
        echo "🆕 Deploying $project (no existing deployment)..."
        bash deploy.sh
    fi
    echo ""
done
echo "✅ Cleanup complete!"
