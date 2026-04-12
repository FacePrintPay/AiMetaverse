#!/bin/bash
echo "Scan fingerprint to authorize GitHub push..."
if termux-fingerprint | grep -q '"auth_result":"AUTH_RESULT_SUCCESS"'; then
    echo "✅ Identity verified."
    # Load your GitHub token (you must set this once)
    if [ ! -f ~/.gh_token ]; then
        echo "⚠️  Token not found. Run setup first."
        exit 1
    fi
    TOKEN=$(cat ~/.gh_token | tr -d '\r\n')
    # Go to repo
    cd ~/kre8tive_ecosystem/AiKre8tive-Stargate || { echo "❌ Repo not found"; exit 1; }
    # Clean lock
    rm -f .git/index.lock
    # Set remote with correct owner: TheKre8tive
    git remote set-url origin "https://${TOKEN}@github.com/TheKre8tive/AiKre8tive-Stargate.git"
    # Commit & push
    git add .
    git commit -m "🤖 Bio-authorized push from Sovereign AI" --allow-empty
    git push origin main
    if [ $? -eq 0 ]; then
        echo "🚀 SUCCESS: Code pushed under sovereign identity."
    else
        echo "💥 FAILED: Check token or network."
    fi
else
    echo "❌ Fingerprint auth failed. Access denied."
    exit 1
fi
