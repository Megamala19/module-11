#!/usr/bin/env bash
# =============================================================
# Git Hands-On Lab — Clean up and push back to remote
# Based on: 5__Git-HOL.docx   (Hands-on ID: Git-T03-HOL_002 prerequisite)
#
# Objective:
#   - Verify master is in a clean state
#   - List all available branches
#   - Pull the latest changes from the remote into master
#   - Push any pending local changes back to the remote
#   - Confirm the changes are reflected on the remote
#
# Usage:
#   1. Run this INSIDE an existing Git repo that already has a remote
#      configured (e.g. "GitDemo" from the earlier labs).
#   2. bash cleanup_push_setup.sh
# =============================================================

set -e

PROJECT_DIR="GitDemo"
TRUNK="master"   # change to "main" if your repo uses that
REMOTE="origin"

# ------------------------------------------------------------
# Step 0: Move into the repo if run from one level above it
# ------------------------------------------------------------
if [ ! -d ".git" ] && [ -d "$PROJECT_DIR/.git" ]; then
    echo "Moving into existing repo: $PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

if [ ! -d ".git" ]; then
    echo "❌ No Git repository found here (or in ./$PROJECT_DIR)."
    echo "   Run this script from inside your Git repo, or set PROJECT_DIR"
    echo "   to the correct path at the top of this script."
    exit 1
fi

git checkout "$TRUNK"

echo
echo "--- 1. Verify master is in a clean state ---"
git status

echo
echo "--- 2. List all available branches (local + remote) ---"
git branch -a

echo
echo "--- 3. Pull the remote repository into master ---"
git pull "$REMOTE" "$TRUNK"

echo
echo "--- 4. Push pending local changes to the remote ---"
# Only pushes if there is something to push; safe to re-run.
if git log "$REMOTE/$TRUNK..$TRUNK" --oneline | grep -q .; then
    git push "$REMOTE" "$TRUNK"
else
    echo "Nothing to push — local $TRUNK is already up to date with $REMOTE/$TRUNK."
fi

echo
echo "--- 5. Verify the changes are reflected on the remote ---"
git fetch "$REMOTE"
echo "Local  $TRUNK:  $(git rev-parse "$TRUNK")"
echo "Remote $TRUNK:  $(git rev-parse "$REMOTE/$TRUNK")"
if [ "$(git rev-parse "$TRUNK")" = "$(git rev-parse "$REMOTE/$TRUNK")" ]; then
    echo "✅ Local and remote '$TRUNK' are in sync."
else
    echo "⚠️  Local and remote '$TRUNK' differ — check git status / git log."
fi

echo
echo "--- Final status ---"
git status
git log --oneline --graph --decorate -5

echo
echo "✅ Done. Working directory cleaned up and synced with '$REMOTE/$TRUNK'."
