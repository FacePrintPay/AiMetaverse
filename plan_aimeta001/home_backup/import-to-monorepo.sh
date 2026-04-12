#!/usr/bin/env bash set -euo pipefail

import-to-monorepo.sh

Imports all non-fork, non-archived repos from SOURCE_OWNER into a single monorepo

preserving history by moving each repo into a subdirectory named after the repo.



Defaults: DRY_RUN=true (no remote changes). Edit and set DRY_RUN=false to perform.



Prereqs:

- gh CLI authenticated (gh auth login)

- git

- pip3 install git-filter-repo

- jq



Usage:

1) Edit variables below (TARGET_ORG, MONO_REPO_NAME, VISIBILITY) as needed.

2) Run: ./import-to-monorepo.sh



Notes:

- Issues / PRs / releases / wikis are NOT migrated by this script.

- Test on 1 repo by setting TEST_ONLY_REPO variable to repo name.

===== CONFIG - EDIT BEFORE RUNNING =====

SOURCE_OWNER="FacePrintPay"                     # owner to import from TARGET_ORG="Kre8tiveKonceptz"                  # target org/login (change if different) MONO_REPO_NAME="kre8tive-konceptz-monorepo"    # desired monorepo name VISIBILITY="private"                            # "private" or "public" INCLUDE_FORKS=false                             # we will skip forks INCLUDE_ARCHIVED=false                          # skip archived repos PRESERVE_HISTORY=true                           # true = preserve history (recommended) POST_IMPORT_UPDATE_ORIGINAL_README=true         # update README in original repo pointing to monorepo POST_IMPORT_ARCHIVE_ORIGINAL=true               # archive original repo after update MIGRATE_ISSUES=false                            # not implemented here; set false REWRITE_WORKFLOWS_LATER=true                    # plan to rewrite CI later DRY_RUN=true                                    # set to false to actually push & change remotes CLONE_DIR="$(pwd)/monorepo-import-workdir" PARALLEL_JOBS=1                                 # set >1 to run parallel imports (watch resources) TEST_ONLY_REPO=""                                # set to a single repo name to test (empty = all)

===== END CONFIG =====

echo "CONFIG:" echo "  SOURCE_OWNER=$SOURCE_OWNER" echo "  TARGET_ORG=$TARGET_ORG" echo "  MONO_REPO_NAME=$MONO_REPO_NAME" echo "  VISIBILITY=$VISIBILITY" echo "  INCLUDE_FORKS=$INCLUDE_FORKS" echo "  INCLUDE_ARCHIVED=$INCLUDE_ARCHIVED" echo "  POST_IMPORT_UPDATE_ORIGINAL_README=$POST_IMPORT_UPDATE_ORIGINAL_README" echo "  POST_IMPORT_ARCHIVE_ORIGINAL=$POST_IMPORT_ARCHIVE_ORIGINAL" echo "  DRY_RUN=$DRY_RUN" echo

read -p "Type YES to continue (or Ctrl-C to abort): " CONF if [[ "$CONF" != "YES" ]]; then echo "Aborting." exit 1 fi

mkdir -p "$CLONE_DIR" cd "$CLONE_DIR"

1) Ensure target monorepo exists (create if missing)

if gh repo view "${TARGET_ORG}/${MONO_REPO_NAME}" >/dev/null 2>&1; then echo "Monorepo exists: ${TARGET_ORG}/${MONO_REPO_NAME}" else echo "Monorepo does not exist. Creating ${TARGET_ORG}/${MONO_REPO_NAME} with visibility=${VISIBILITY}" if [[ "$DRY_RUN" == "false" ]]; then gh repo create "${TARGET_ORG}/${MONO_REPO_NAME}" --"${VISIBILITY}" --confirm else echo "[DRY RUN] gh repo create ${TARGET_ORG}/${MONO_REPO_NAME} --${VISIBILITY} --confirm" fi fi

Get monorepo clone URL (SSH preferred)

MONO_SSH_URL="$(gh repo view "${TARGET_ORG}/${MONO_REPO_NAME}" --json sshUrl -q .sshUrl 2>/dev/null || true)" if [[ -z "$MONO_SSH_URL" ]]; then MONO_HTTP_URL="$(gh repo view "${TARGET_ORG}/${MONO_REPO_NAME}" --json url -q .url)" MONO_SSH_URL="$MONO_HTTP_URL" fi

Clone monorepo locally (or init empty)

if [[ ! -d mono-local ]]; then if [[ "$DRY_RUN" == "false" ]]; then git clone "$MONO_SSH_URL" mono-local else echo "[DRY RUN] git clone $MONO_SSH_URL mono-local (simulated)" mkdir -p mono-local cd mono-local git init git checkout -b main || true cd .. fi fi

2) Build list of source repos (non-forks, non-archived unless configured)

echo "Fetching repo list from ${SOURCE_OWNER}..." REPO_JSON="$(mktemp)" gh repo list "$SOURCE_OWNER" --limit 1000 --json name,sshUrl,isFork,archived,defaultBranch > "$REPO_JSON"

REPOS_TO_IMPORT=() while IFS= read -r entry; do name="$(echo "$entry" | jq -r '.name')" isFork="$(echo "$entry" | jq -r '.isFork')" archived="$(echo "$entry" | jq -r '.archived')" if [[ -n "$TEST_ONLY_REPO" && "$name" != "$TEST_ONLY_REPO" ]]; then continue fi if [[ "$isFork" == "true" && "$INCLUDE_FORKS" != "true" ]]; then echo "Skipping fork: $name" continue fi if [[ "$archived" == "true" && "$INCLUDE_ARCHIVED" != "true" ]]; then echo "Skipping archived: $name" continue fi REPOS_TO_IMPORT+=("$name") done < <(jq -c '.[]' "$REPO_JSON")

echo "Selected ${#REPOS_TO_IMPORT[@]} repos to import."

if [[ ${#REPOS_TO_IMPORT[@]} -eq 0 ]]; then echo "No repos to import. Exiting." exit 0 fi

Helper: import single repo

import_repo() { local repo="$1" echo echo "=== IMPORT: $repo ===" local tmpdir="${CLONE_DIR}/${repo}" rm -rf "$tmpdir" echo "Cloning ${SOURCE_OWNER}/${repo}..." if [[ "$DRY_RUN" == "false" ]]; then git clone "git@github.com:${SOURCE_OWNER}/${repo}.git" "$tmpdir" else echo "[DRY RUN] git clone git@github.com:${SOURCE_OWNER}/${repo}.git $tmpdir" mkdir -p "$tmpdir" pushd "$tmpdir" >/dev/null git init git checkout -b tmp || true popd >/dev/null fi

pushd "$tmpdir" >/dev/null DEFAULT_BRANCH="$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || true)" if [[ -z "$DEFAULT_BRANCH" ]]; then DEFAULT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)" else DEFAULT_BRANCH="${DEFAULT_BRANCH#origin/}" fi echo "Default branch detected: $DEFAULT_BRANCH" git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout -b "$DEFAULT_BRANCH" || true

if command -v git-filter-repo >/dev/null 2>&1; then echo "Running git-filter-repo --to-subdirectory-filter $repo" if [[ "$DRY_RUN" == "false" ]]; then git filter-repo --to-subdirectory-filter "$repo" else echo "[DRY RUN] git filter-repo --to-subdirectory-filter $repo" fi else echo "ERROR: git-filter-repo required but not found. Install: pip3 install git-filter-repo" popd >/dev/null return 1 fi popd >/dev/null

pushd "$CLONE_DIR/mono-local" >/dev/null if [[ "$DRY_RUN" == "false" ]]; then git remote remove import-temp 2>/dev/null || true git remote add import-temp "$tmpdir" git fetch import-temp "+refs/heads/:refs/heads/import/${repo}/" 2>/dev/null || true BRANCH="$(git --no-pager ls-remote --symref "$tmpdir" HEAD 2>/dev/null | awk '/^ref:/ {print $3}' | sed 's@refs/heads/@@' || true)" if [[ -z "$BRANCH" ]]; then BRANCH="$(git -C "$tmpdir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)" fi git fetch "$tmpdir" "$BRANCH:$BRANCH-import-${repo}" 2>/dev/null || true git branch -f "import/${repo}" "${BRANCH}-import-${repo}" || true git remote remove import-temp || true echo "Created branch import/${repo} in mono-local." else echo "[DRY RUN] Would create import/${repo} branch in mono-local using rewritten repo at $tmpdir" fi popd >/dev/null

if [[ "$DRY_RUN" == "false" ]]; then rm -rf "$tmpdir" else echo "[DRY RUN] Would remove temporary clone $tmpdir" fi }

export -f import_repo export CLONE_DIR SOURCE_OWNER DRY_RUN

if [[ "$PARALLEL_JOBS" -gt 1 ]]; then printf "%s\n" "${REPOS_TO_IMPORT[@]}" | xargs -n1 -P"$PARALLEL_JOBS" -I% bash -c 'import_repo "%"' else for r in "${REPOS_TO_IMPORT[@]}"; do import_repo "$r" done fi

pushd "$CLONE_DIR/mono-local" >/dev/null git checkout -B main || true

for r in "${REPOS_TO_IMPORT[@]}"; do import_branch="import/${r}" if git show-ref --verify --quiet "refs/heads/${import_branch}"; then echo "Merging ${import_branch} into main..." if [[ "$DRY_RUN" == "false" ]]; then git merge --allow-unrelated-histories --no-ff -m "Merge ${r} into monorepo (preserve history)" "${import_branch}" || { echo "Merge conflict merging ${import_branch}. Resolve manually in ${CLONE_DIR}/mono-local" exit 1 } else echo "[DRY RUN] git merge --allow-unrelated-histories --no-ff ${import_branch}" fi else echo "Import branch ${import_branch} not present; skipping merge for ${r}" fi done

if [[ "$DRY_RUN" == "false" ]]; then echo "Pushing main to ${TARGET_ORG}/${MONO_REPO_NAME}..." git push origin main else echo "[DRY RUN] Would push main to origin" fi popd >/dev/null

if [[ "$POST_IMPORT_UPDATE_ORIGINAL_README" == "true" || "$POST_IMPORT_ARCHIVE_ORIGINAL" == "true" ]]; then for r in "${REPOS_TO_IMPORT[@]}"; do echo echo "=== POST-IMPORT ACTIONS for $r ===" if [[ "$POST_IMPORT_UPDATE_ORIGINAL_README" == "true" ]]; then README_MSG="This repository has been imported into the monorepo ${TARGET_ORG}/${MONO_REPO_NAME} under the directory /${r}.\n\nPlease see the monorepo: https://github.com/${TARGET_ORG}/${MONO_REPO_NAME}\n\nThis repository is archived and retained for history." if [[ "$DRY_RUN" == "false" ]]; then exists=$(gh api repos/"${SOURCE_OWNER}"/"${r}"/contents/README.md -q '.type' 2>/dev/null || echo "absent") if [[ "$exists" == "file" ]]; then sha=$(gh api repos/"${SOURCE_OWNER}"/"${r}"/contents/README.md -q '.sha') gh api -X PUT repos/"${SOURCE_OWNER}"/"${r}"/contents/README.md 
-f message="chore: point to monorepo ${TARGET_ORG}/${MONO_REPO_NAME}" 
-f content="$(printf "%s\n" "$README_MSG" | base64 -w 0)" 
-F sha="$sha" else gh api -X PUT repos/"${SOURCE_OWNER}"/"${r}"/contents/README.md 
-f message="chore: point to monorepo ${TARGET_ORG}/${MONO_REPO_NAME}" 
-f content="$(printf "%s\n" "$README_MSG" | base64 -w 0)" fi echo "Updated README for ${r}" else echo "[DRY RUN] Would update README of ${SOURCE_OWNER}/${r}" fi fi

if [[ "$POST_IMPORT_ARCHIVE_ORIGINAL" == "true" ]]; then
  if [[ "$DRY_RUN" == "false" ]]; then
    gh api -X PATCH repos/"${SOURCE_OWNER}"/"${r}" -f archived=true >/dev/null
    echo "Archived ${SOURCE_OWNER}/${r}"
  else
    echo "[DRY RUN] Would archive ${SOURCE_OWNER}/${r}"
  fi
fi

done fi

echo echo "IMPORT SCRIPT COMPLETE (DRY_RUN=$DRY_RUN)."
