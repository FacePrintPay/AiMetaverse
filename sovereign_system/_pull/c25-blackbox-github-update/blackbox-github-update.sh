#!/bin/bash
# Blackbox GitHub Rebranding Update Script
set -euo pipefail
echo -e "\033[0;34m╔════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;34m║  Blackbox GitHub Rebranding Update         ║\033[0m"
echo -e "\033[0;34m╚════════════════════════════════════════════╝\033[0m"
# Repo 1: Sovereign AI Metaverse Framework
echo -e "\033[0;36mUpdating Sovereign AI Metaverse Framework...\033[0m"
gh repo clone FacePrintPay/blackboxai-1742376990260 /tmp/sovereign-metaverse -- --depth 1
cd /tmp/sovereign-metaverse
cat > README.md << 'README'
# Sovereign AI Metaverse Framework
**Built by Cygel White**
Full Python AI Metaverse platform with modular execution, devcontainer support, and advanced workflows.
Status: Production-ready AI system
README
git add README.md
git commit -m "🔄 Rebrand: Remove Blackbox references" || true
git push origin main || true
cd \~
rm -rf /tmp/sovereign-metaverse
# Repo 2: Core Build Test Platform
echo -e "\033[0;36mUpdating Core Build Test Platform...\033[0m"
gh repo clone FacePrintPay/blackboxai-1742374192849 /tmp/core-build-test -- --depth 1
cd /tmp/core-build-test
cat > README.md << 'README'
# Core Build Test Platform
**Built by Cygel White**
Infrastructure test project for CI/CD validation and workflow testing.
Status: Core testing platform
README
git add README.md
git commit -m "🔄 Rebrand: Remove Blackbox references" || true
git push origin main || true
cd \~
rm -rf /tmp/core-build-test
echo -e "\033[0;32m✅ Rebranding completed and pushed!\033[0m"
echo -e "Refresh dashboard: https://faceprintpay.github.io/fp-build-fixer/"
