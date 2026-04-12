#!/bin/bash
# Link all Vercel projects to GitHub repos
echo "🔗 Linking Vercel projects to GitHub..."
PROJECTS_DIR="$HOME/kre8tive-empire/vercel-master/projects"
for project_dir in "$PROJECTS_DIR"/*; do
    project=$(basename "$project_dir")
    echo ""
    echo "Processing: $project"
    cd "$project_dir"
    # Check if GitHub repo exists
    if gh repo view "FacePrintPay/$project" &>/dev/null; then
        echo "  ✅ GitHub repo exists"
        # Add remote if not exists
        if ! git remote get-url origin &>/dev/null; then
            git remote add origin "https://github.com/FacePrintPay/$project.git"
            echo "  🔗 Remote added"
        fi
        # Push to GitHub
        git push -u origin main --force
        echo "  📤 Pushed to GitHub"
        # Link to Vercel
        vercel link --yes
        echo "  🔗 Linked to Vercel"
    else
        echo "  ⚠️  Creating GitHub repo..."
        gh repo create "FacePrintPay/$project" --public --source=. --push
        vercel link --yes
        echo "  ✅ Repo created and linked"
    fi
done
echo ""
echo "✅ All projects linked!"
