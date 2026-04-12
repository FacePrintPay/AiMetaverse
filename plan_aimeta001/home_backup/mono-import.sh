#!/usr/bin/env bash
set -e

# ===== CONFIG =====
SOURCE_REPO="git@github.com:FacePrintPay/REPO_NAME.git"
MONO_REPO="git@github.com:Kre8tiveKonceptz/kre8tive-monorepo.git"
SUBDIR_NAME="REPO_NAME"
# ==================

echo "▶ Cloning source repo..."
git clone "$SOURCE_REPO" source-repo
cd source-repo

echo "▶ Rewriting history into subdirectory: $SUBDIR_NAME"
git filter-repo --to-subdirectory-filter "$SUBDIR_NAME"

cd ..

echo "▶ Cloning monorepo..."
git clone "$MONO_REPO" monorepo
cd monorepo

echo "▶ Adding rewritten repo as remote..."
git remote add import ../source-repo

echo "▶ Fetching history..."
git fetch import

echo "▶ Merging into monorepo (history preserved)..."
git checkout main || git checkout -b main
git merge import/main --allow-unrelated-histories -m "Import $SUBDIR_NAME into monorepo"

echo "▶ Pushing to origin..."
git push origin main

echo "✅ DONE. Monorepo updated successfully."
