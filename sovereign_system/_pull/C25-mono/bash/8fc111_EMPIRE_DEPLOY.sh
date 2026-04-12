#!/bin/bash
TOKEN="${TOKEN}"
OWNER="FacePrintPay"
LOG=~/EMPIRE_DEPLOY_$(date +%Y%m%d_%H%M%S).log
DEST=~/constellation25-mono

echo "====== EMPIRE DEPLOY STARTED $(date) ======" | tee $LOG

# STEP 1: FREE SPACE FIRST
echo "--- Freeing space ---" | tee -a $LOG
rm -rf ~/node_modules ~/.npm/_cacache ~/.gradle ~/nltk_data 2>/dev/null
find ~ -name "node_modules" -type d -not -path "*/constellation25-mono/*" 2>/dev/null | xargs rm -rf 2>/dev/null
df -h | grep dm-12 | tee -a $LOG

# STEP 2: CREATE MONOREPO LOCALLY
echo "--- Setting up monorepo ---" | tee -a $LOG
rm -rf $DEST
mkdir -p $DEST
cd $DEST
git init
git remote add origin "https://$TOKEN@github.com/$OWNER/constellation25.git" 2>/dev/null || true

# STEP 3: COPY ALL LOCAL PROJECTS
echo "--- Copying local projects ---" | tee -a $LOG
for dir in ~/AiKre8tive ~/AiMeta ~/AiMetaverse ~/Agentik ~/agentik ~/videocourts-justice-stack ~/VideoCourts-Complete ~/sovereign-gtp ~/SovereignGTP ~/PaThosAi ~/PlanetaryAgents ~/VeRseD_Ai ~/kreativekoncepts ~/ai-kre8tive-stargate ~/constellation25 ~/Constellation25 ~/FacePrintPay ~/TheKre8tive ~/sentinel-lens ~/coral-server; do
  if [ -d "$dir" ]; then
    name=$(basename "$dir")
    echo "  + $name" | tee -a $LOG
    cp -r "$dir" "$DEST/$name" 2>/dev/null
  fi
done

# STEP 4: CLONE MISSING REPOS FROM GITHUB
echo "--- Cloning from GitHub ---" | tee -a $LOG
REPOS="videocourts c25-agent-core c25-agent-dashboard c25-agent-api c25-agent-deploy aikre8tive AiKre8tive-Stargate SovereignGTP PaThosAi kreativekoncepts VeRseD_Ai agentik fp-build-fixer sentinel-lens"
for repo in $REPOS; do
  if [ ! -d "$DEST/$repo" ]; then
    echo "  Cloning $repo..." | tee -a $LOG
    git clone --depth=1 "https://$TOKEN@github.com/$OWNER/$repo.git" "$DEST/$repo" 2>/dev/null && echo "  ✓ $repo" | tee -a $LOG || echo "  ✗ $repo failed" | tee -a $LOG
  fi
done

# STEP 5: COMMIT AND PUSH EVERYTHING
echo "--- Pushing to constellation25 ---" | tee -a $LOG
cd $DEST
# Remove nested .git dirs to avoid submodule issues
find . -mindepth 2 -name ".git" -type d 2>/dev/null | xargs rm -rf
git add .
git commit -m "SOVEREIGN EMPIRE - Full consolidation $(date)" 2>/dev/null | tee -a $LOG
git push "https://$TOKEN@github.com/$OWNER/constellation25.git" main --force 2>&1 | tee -a $LOG

# STEP 6: TRIGGER VERCEL (if token exists)
echo "--- Checking Vercel ---" | tee -a $LOG
if [ -f ~/.vercel/auth.json ]; then
  VERCEL_TOKEN=$(cat ~/.vercel/auth.json | jq -r '.token' 2>/dev/null)
  curl -s -X POST "https://api.vercel.com/v1/deployments" \
    -H "Authorization: Bearer $VERCEL_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"constellation25","gitSource":{"type":"github","repoId":"constellation25","ref":"main"}}' | jq '.url' | tee -a $LOG
fi

echo "====== DONE $(date) ======" | tee -a $LOG
echo "Check: https://github.com/$OWNER/constellation25" | tee -a $LOG
df -h | grep dm-12 | tee -a $LOG
