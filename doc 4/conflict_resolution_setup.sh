#!/usr/bin/env bash
# =============================================================
# Git Hands-On Lab — Conflict Resolution automation script
# Based on: 4__Git-HOL.docx   (Hands-on ID: Git-T03-HOL_001 prerequisite)
#
# Objective:
#   - Create a branch "GitWork", add/modify hello.xml, commit
#   - On master, add/modify hello.xml differently, commit
#   - Merge the branch into master -> triggers a conflict on purpose
#   - Resolve the conflict, commit the resolution
#   - Add a backup-file pattern to .gitignore, commit
#   - List and delete the merged branch, review the log
#
# NOTE ON THE CONFLICT STEP:
#   A real conflict must be resolved by a human (or a merge tool like
#   P4Merge / VS Code's 3-way merge editor) reading both versions and
#   deciding what the final content should be. This script triggers the
#   conflict and then applies a simple DEFAULT resolution (keep both
#   pieces of content, one after another) so the walkthrough can run
#   end-to-end non-interactively. Skip to the "RESOLVE" section below
#   and edit hello.xml yourself if you want to practice manual/P4Merge
#   resolution instead.
#
# Usage:
#   1. Run this INSIDE an existing Git repo (e.g. "GitDemo" from the
#      earlier labs). If none exists, this script creates one.
#   2. bash conflict_resolution_setup.sh
# =============================================================

set -e

PROJECT_DIR="GitDemo"
TRUNK="master"                 # change to "main" if your repo uses that
BRANCH_NAME="GitWork"
FILE="hello.xml"
BACKUP_PATTERN="*.bak"

BRANCH_CONTENT='<hello><message>Hello from GitWork branch</message></hello>'
MASTER_CONTENT='<hello><message>Hello from master</message></hello>'

BRANCH_COMMIT_MSG="Add hello.xml on $BRANCH_NAME"
MASTER_COMMIT_MSG="Add hello.xml on $TRUNK with different content"
RESOLVE_COMMIT_MSG="Resolve merge conflict in $FILE"
GITIGNORE_COMMIT_MSG="Ignore backup files"

# ------------------------------------------------------------
# Step 0: Ensure we're in a repo with a clean, existing trunk
# ------------------------------------------------------------
if [ ! -d ".git" ]; then
    if [ -d "$PROJECT_DIR/.git" ]; then
        echo "Moving into existing repo: $PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        echo "No Git repo found. Initializing a new one in ./$PROJECT_DIR ..."
        mkdir -p "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        git init
        git branch -M "$TRUNK"
    fi
fi

if ! git rev-parse --verify "$TRUNK" >/dev/null 2>&1; then
    echo "No '$TRUNK' commit yet — creating an initial commit."
    echo "Initial commit" > README.md
    git add README.md
    git commit -m "Initial commit"
    git branch -M "$TRUNK"
fi

git checkout "$TRUNK"

echo
echo "--- 1. Verify master is clean ---"
git status

echo
echo "--- 2. Create branch '$BRANCH_NAME' and add $FILE ---"
git branch "$BRANCH_NAME"
git checkout "$BRANCH_NAME"
echo "$BRANCH_CONTENT" > "$FILE"

echo
echo "--- 3. Observe status (untracked/modified) ---"
git status

echo
echo "--- 4. Commit the change on the branch ---"
git add "$FILE"
git commit -m "$BRANCH_COMMIT_MSG"

echo
echo "--- 5. Switch to master ---"
git checkout "$TRUNK"

echo
echo "--- 6. Add $FILE to master with DIFFERENT content ---"
echo "$MASTER_CONTENT" > "$FILE"

echo
echo "--- 7. Commit the change on master ---"
git add "$FILE"
git commit -m "$MASTER_COMMIT_MSG"

echo
echo "--- 8. Log graph before merging ---"
git log --oneline --graph --decorate --all

echo
echo "--- 9. Command-line diff between master and $BRANCH_NAME ---"
git diff "$TRUNK" "$BRANCH_NAME" || true

echo
echo "--- 10. Visual diff with P4Merge (optional, Windows GUI tool) ---"
if git config --get diff.tool >/dev/null 2>&1; then
    git difftool "$TRUNK" "$BRANCH_NAME" || true
else
    echo "P4Merge not configured. To enable it:"
    echo '  git config --global diff.tool p4merge'
    echo '  git config --global difftool.p4merge.cmd "p4merge \"$LOCAL\" \"$REMOTE\""'
fi

echo
echo "--- 11. Merge '$BRANCH_NAME' into '$TRUNK' (conflict expected) ---"
set +e
git merge "$BRANCH_NAME"
MERGE_EXIT=$?
set -e

echo
echo "--- 12. Observe the git conflict markup ---"
if [ $MERGE_EXIT -ne 0 ]; then
    echo "Conflict detected in $FILE (as expected):"
    cat "$FILE"
    git status

    echo
    echo "=== RESOLVE ==="
    echo "Applying DEFAULT resolution: keep both messages."
    echo "(Edit $FILE by hand instead if you want to practice this manually"
    echo " or with P4Merge's 3-way merge tool: git mergetool)"
    cat > "$FILE" <<EOF
<hello>
  <message>Hello from master</message>
  <message>Hello from GitWork branch</message>
</hello>
EOF

    echo
    echo "--- 13/14. Mark resolved and commit ---"
    git add "$FILE"
    git commit -m "$RESOLVE_COMMIT_MSG"
else
    echo "No conflict occurred (contents didn't collide) — merge completed cleanly."
fi

echo
echo "--- 15. Status after resolving; add backup files to .gitignore ---"
git status
touch .gitignore
grep -qxF "$BACKUP_PATTERN" .gitignore || echo "$BACKUP_PATTERN" >> .gitignore
cat .gitignore

echo
echo "--- 16. Commit the .gitignore change ---"
git add .gitignore
git commit -m "$GITIGNORE_COMMIT_MSG"

echo
echo "--- 17. List all branches ---"
git branch -a

echo
echo "--- 18. Delete the branch that was merged into master ---"
git branch -d "$BRANCH_NAME"

echo
echo "--- 19. Final log graph ---"
git log --oneline --graph --decorate

echo
echo "✅ Done. Conflict in $FILE resolved, merged into $TRUNK, branch deleted."
echo "   Push with: git push origin $TRUNK"
