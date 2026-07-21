#!/usr/bin/env bash
# =============================================================
# Git Hands-On Lab — Branching & Merging automation script
# Based on: 3__Git-HOL.docx
#
# Objective:
#   - Create a new branch "GitNewBranch"
#   - Make changes on it, commit them
#   - Switch back to master, diff master vs branch
#   - Merge the branch into master
#   - View history with git log --oneline --graph --decorate
#   - Delete the branch after merging
#
# Usage:
#   1. Run this INSIDE an existing Git repo (e.g. the "GitDemo" repo
#      from the earlier labs). If none exists, this script creates one.
#   2. bash branching_merging_setup.sh
# =============================================================

set -e

PROJECT_DIR="GitDemo"
BRANCH_NAME="GitNewBranch"
TRUNK="master"             # change to "main" if your repo uses that
NEW_FILE="branch_feature.txt"
NEW_FILE_CONTENT="This content was added on $BRANCH_NAME."
COMMIT_MESSAGE="Add $NEW_FILE on $BRANCH_NAME"
MERGE_COMMIT_MESSAGE="Merge $BRANCH_NAME into $TRUNK"

# ------------------------------------------------------------
# Step 0: Make sure we're inside a Git repo with at least one commit
# ------------------------------------------------------------
if [ ! -d ".git" ]; then
    if [ -d "$PROJECT_DIR/.git" ]; then
        echo "Moving into existing repo: $PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        echo "No Git repo found here or at ./$PROJECT_DIR."
        echo "Initializing a new one in ./$PROJECT_DIR ..."
        mkdir -p "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        git init
        git branch -M "$TRUNK"
    fi
fi

# Make sure there is at least one commit on the trunk (branching needs it)
if ! git rev-parse --verify "$TRUNK" >/dev/null 2>&1; then
    echo "No '$TRUNK' branch/commit yet — creating an initial commit."
    echo "Initial commit" > README.md
    git add README.md
    git commit -m "Initial commit"
    git branch -M "$TRUNK"
fi

git checkout "$TRUNK"

echo
echo "=========== BRANCHING ==========="

echo
echo "--- 1. Create a new branch '$BRANCH_NAME' ---"
git branch "$BRANCH_NAME"

echo
echo "--- 2. List all local and remote branches (note the '*' = current branch) ---"
git branch -a

echo
echo "--- 3. Switch to '$BRANCH_NAME' and add a file with content ---"
git checkout "$BRANCH_NAME"
echo "$NEW_FILE_CONTENT" > "$NEW_FILE"
cat "$NEW_FILE"

echo
echo "--- 4. Commit the changes on the branch ---"
git add "$NEW_FILE"
git commit -m "$COMMIT_MESSAGE"

echo
echo "--- 5. Check status on the branch ---"
git status

echo
echo "=========== MERGING ==========="

echo
echo "--- 1. Switch back to '$TRUNK' ---"
git checkout "$TRUNK"

echo
echo "--- 2. Command-line diff: $TRUNK vs $BRANCH_NAME ---"
git diff "$TRUNK" "$BRANCH_NAME"

echo
echo "--- 3. Visual diff with P4Merge (optional, Windows GUI tool) ---"
if git config --get diff.tool >/dev/null 2>&1; then
    echo "Opening configured diff tool..."
    git difftool "$TRUNK" "$BRANCH_NAME" || true
else
    echo "P4Merge not configured as difftool. To enable it, run:"
    echo '  git config --global diff.tool p4merge'
    echo '  git config --global difftool.p4merge.cmd "p4merge \"$LOCAL\" \"$REMOTE\""'
    echo "Then re-run: git difftool $TRUNK $BRANCH_NAME"
fi

echo
echo "--- 4. Merge '$BRANCH_NAME' into '$TRUNK' ---"
git merge --no-ff "$BRANCH_NAME" -m "$MERGE_COMMIT_MESSAGE"

echo
echo "--- 5. View history graph after merging ---"
git log --oneline --graph --decorate --all

echo
echo "--- 6. Delete the branch after merging, then check status ---"
git branch -d "$BRANCH_NAME"
git status

echo
echo "✅ Done. '$BRANCH_NAME' was merged into '$TRUNK' and deleted."
echo "   Push the result with: git push origin $TRUNK"
