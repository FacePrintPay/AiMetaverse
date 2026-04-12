#!/bin/bash
# Deploy all Vercel projects
PROJECTS_DIR="$HOME/kre8tive-empire/vercel-master/projects"
echo "🚀 DEPLOYING ALL VERCEL PROJECTS"
echo "================================="
echo ""
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_PROJECTS=()
for project_dir in "$PROJECTS_DIR"/*; do
    project=$(basename "$project_dir")
    echo ""
    echo "📦 Deploying: $project"
    echo "-----------------------------------"
    cd "$project_dir"
    if bash deploy.sh; then
        echo "✅ $project - SUCCESS"
        ((SUCCESS_COUNT++))
    else
        echo "❌ $project - FAILED"
        ((FAIL_COUNT++))
        FAILED_PROJECTS+=("$project")
    fi
done
echo ""
echo "================================="
echo "📊 DEPLOYMENT SUMMARY"
echo "================================="
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
if [ ${#FAILED_PROJECTS[@]} -gt 0 ]; then
    echo ""
    echo "Failed projects:"
    for proj in "${FAILED_PROJECTS[@]}"; do
        echo "  - $proj"
    done
fi
echo ""
echo "🎉 Deployment complete!"
